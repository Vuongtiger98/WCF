# frozen_string_literal: true

# Offline inspection only: never evaluates RGSS code or rewrites Scripts.rvdata2.
require 'zlib'
require 'digest'
require 'json'
require 'ripper'

module ScriptInventory
  ROOT = File.expand_path('..', __dir__)
  INVALID = { '\\'=>'&', '/'=>'&', ':'=>';', '*'=>'°', '?'=>'!', '<'=>'«', '>'=>'»', '|'=>'¦', '"'=>"'" }.freeze
  def self.filename(name)
    name.each_char.map { |c| INVALID.fetch(c, c) }.join + '.rb'
  end

  def self.entries
    Marshal.load(File.binread(File.join(ROOT, 'Data/Scripts.rvdata2'))).each_with_index.map do |entry, index|
      source = Zlib::Inflate.inflate(entry[2]).force_encoding('UTF-8')
      path = File.join(ROOT, 'Scripts', filename(entry[1]))
      exported = File.file?(path) ? File.binread(path).force_encoding('UTF-8') : nil
      tokens = Ripper.lex(source).reject { |t| [:on_comment, :on_embdoc_beg, :on_embdoc, :on_embdoc_end, :on_sp, :on_nl, :on_ignored_nl].include?(t[1]) }
      {
        index: index, id: entry[0], name: entry[1], source: source, path: path,
        active: !tokens.empty?, syntax: !Ripper.sexp(source).nil?,
        sha256: Digest::SHA256.hexdigest(source),
        export: exported.nil? ? 'missing' : exported == source ? 'exact' :
          exported.gsub(/\r\n?/, "\n") == source.gsub(/\r\n?/, "\n") ? 'line-endings-only' : 'different',
        urls: source.lines.first(180).join.scan(%r{https?://[^\s<>"')]+}).uniq,
        headers: source.lines.first(180).each_with_index.filter_map do |line, n|
          {line: n + 1, text: line.strip} if line.match?(/author|created by|by |by:|version|terms|licen[sc]e|credit|copyright|requires/i)
        end
      }
    end
  end

  def self.tokens(source)
    Ripper.lex(source).reject { |t| [:on_comment, :on_embdoc_beg, :on_embdoc, :on_embdoc_end, :on_sp, :on_nl, :on_ignored_nl].include?(t[1]) }.map { |t| [t[1], t[2]] }
  end

  def self.const_name(node)
    return '' unless node.is_a?(Array)
    return node[1] if node[0] == :@const || node[0] == :@ident || node[0] == :@kw
    return node.drop(1).map { |n| const_name(n) }.reject(&:empty?).join('::')
  end

  # Structural definitions only. Does not claim that every conditional branch
  # executes, or that a repeated definition is an incompatible overwrite.
  def self.definitions(node, scope = '', singleton = false, result = [])
    return result unless node.is_a?(Array)
    case node[0]
    when :class, :module
      name = const_name(node[1])
      name = scope + '::' + name unless scope.empty? || name.include?('::')
      body = node[0] == :class ? node[3] : node[2]
      definitions(body, name, false, result)
    when :sclass
      target = const_name(node[1])
      definitions(node[2], target == 'self' ? scope : target, true, result)
    when :def
      result << {key: scope + (singleton ? '.' : '#') + node[1][1], line: node[1][2][0]}
      definitions(node[3], scope, singleton, result)
    when :defs
      target = const_name(node[1])
      owner = target == 'self' ? scope : target
      result << {key: owner + '.' + node[3][1], line: node[3][2][0]}
      definitions(node[5], scope, singleton, result)
    else
      node.each { |child| definitions(child, scope, singleton, result) if child.is_a?(Array) }
    end
    result
  end

  def self.markdown(entries)
    lines = ['# Inventory script runtime', '',
      'Snapshot đối chiếu trực tiếp `Data/Scripts.rvdata2`. Slot là chỉ số zero-based của mảng Marshal; không phải thứ tự chữ cái của file export.', '',
      "- Tổng slot: #{entries.length} (gồm placeholder và separator).",
      "- Slot có token Ruby thực thi: #{entries.count { |e| e[:active] }}. Đây là kiểm tra cấu trúc, không chứng minh một tính năng đã được gọi trong game.",
      '- Tác giả, công dụng và dependency của các script bổ sung: [catalogue.md](catalogue.md).',
      '- Cột `exact` khớp byte; `line-endings-only` chỉ khác CRLF/LF; `different` cần xem token và nội dung trước khi đồng bộ.', '',
      '| Slot | Script | Trạng thái mã | Export | SHA-256 runtime (12 ký tự đầu) |',
      '|---:|---|---|---|---|']
    entries.each do |e|
      label = e[:name].empty? ? '(slot rỗng)' : e[:name].gsub('|', '\\|')
      label = "[#{label}](<../../../Scripts/#{filename(e[:name])}>)" if File.file?(e[:path]) && !e[:source].empty?
      state = e[:source].empty? ? 'Rỗng/separator' : e[:active] ? 'Có mã' : 'Comment/tài liệu'
      status = e[:source].empty? ? '—' : e[:export]
      lines << "| #{e[:index]} | #{label} | #{state} | #{status} | `#{e[:sha256][0,12]}` |"
    end
    lines += ['', '## Phạm vi xác minh', '',
      'Inventory không thực thi script game. Các slot chuẩn VX Ace được liệt kê đầy đủ để nhận diện cả code gốc đã chỉnh. File có code nhưng nằm trong nhánh điều kiện không dùng vẫn xuất hiện là “Có mã”.', '',
      'Tái tạo nội dung: `ruby tools/script_inventory.rb markdown`. Đọc chênh lệch: `ruby tools/script_inventory.rb differences`. Kiểm tra token: `ruby tools/script_inventory.rb semantic`.']
    lines.join("\n") + "\n"
  end

  def self.run
    entries = self.entries
    command = ARGV.shift
    case command
    when 'check'
      errors = []
      errors << 'Ruby syntax failure' unless entries.all? { |e| e[:syntax] }
      entries.select { |e| !e[:source].empty? }.each do |e|
        errors << "Missing export #{e[:name]}" if e[:export] == 'missing'
        next unless e[:export] == 'different'
        errors << "Different code #{e[:name]}" unless tokens(e[:source]) == tokens(File.read(e[:path], encoding: 'UTF-8'))
      end
      order = File.readlines(File.join(ROOT, 'Scripts/!script_order.csv'), chomp: true, encoding: 'UTF-8')
      expected = entries.drop(1).map do |e|
        name = filename(e[:name]).sub(/\.rb\z/, '')
        name = '~blank' if name.empty?
        name += '~blank' if e[:source].empty? && !name.end_with?('~blank')
        name
      end
      errors << 'CSV order does not match runtime' unless order == expected
      importer = entries.find { |e| e[:name].strip == 'Easy Script Importer-Exporter' }
      errors << 'Runtime importer mode is not 0' unless importer && importer[:source].match?(/^IMPORT_EXPORT_MODE = 0\s*$/)
      errors.each { |error| puts "ERROR|#{error}" }
      puts "SCRIPT_INVENTORY_AUDIT|slots=#{entries.length}|csv=#{order.length}|errors=#{errors.length}"
      exit 1 unless errors.empty?
    when 'check-patch-scope', 'check-performance-scope', 'check-native-performance-scope', 'check-phone-ui-scope', 'check-phone-open-scope'
      phone_open = command == 'check-phone-open-scope'
      phone_ui = command == 'check-phone-ui-scope'
      native = command == 'check-native-performance-scope'
      performance = command != 'check-patch-scope'
      backup = phone_open ? 'codex_backup_phone_open_20261115' : phone_ui ? 'codex_backup_phone_ui_20261115' : native ? 'codex_backup_performance_native_20261115' :
        performance ? 'codex_backup_performance_20261115' : 'codex_backup_scripts_review_20261030'
      before = Marshal.load(File.binread(File.join(ROOT, 'Data', backup, 'Scripts.rvdata2')))
      after = Marshal.load(File.binread(File.join(ROOT, 'Data/Scripts.rvdata2')))
      raise 'Slot count changed' unless before.length == after.length
      changed = []
      before.zip(after).each_with_index do |(old, current), index|
        raise "Slot identity/order changed #{index}" unless old[0,2] == current[0,2]
        changed << current[1] unless old[2] == current[2]
      end
      expected = (phone_ui || phone_open) ? ['Custom Menu'] : native ? ['KUL Graphics', 'Custom Menu'] :
        ['Custom Menu', 'Game_Map', 'KUL Graphics', 'MOG_Weather_EX', 'Text Over Event']
      expected += ["Galv's Layer Graphics", 'Particles', 'anti-animation lag'] unless performance
      expected.sort!
      raise "Unexpected changed slots: #{changed.inspect}" unless changed.sort == expected
      puts "PATCH_SCOPE_AUDIT|slots=#{after.length}|changed=#{changed.join(',')}|order_preserved=true"
    when 'markdown'
      puts markdown(entries)
    when 'semantic'
      differences = entries.select { |e| e[:export] == 'different' }.reject do |e|
        tokens(e[:source]) == tokens(File.read(e[:path], encoding: 'UTF-8'))
      end
      differences.each { |e| puts "SEMANTIC_DIFFERENCE|#{e[:index]}|#{e[:name]}" }
      puts "SEMANTIC_AUDIT|different=#{differences.length}"
      exit 1 unless differences.empty?
    when 'overrides'
      grouped = Hash.new { |h, k| h[k] = [] }
      entries.each do |e|
        definitions(Ripper.sexp(e[:source])).each { |d| grouped[d[:key]] << [e[:index], e[:name], d[:line]] }
      end
      tracked = ['Game_Player#update_scroll', 'Game_Map#setup', 'Spriteset_Map#update_pictures',
        'Sprite_Picture#update', 'Sprite_Base#dispose_animation', 'Window_Message#process_escape_character',
        'Window_Message#update_placement', 'Scene_Map#update', 'Scene_SimplePhoneChat#apply_choice',
        'Scene_Title#start', 'Scene_Base#terminate', 'SceneManager.goto', 'Game_CharacterBase#update']
      tracked.each { |key| puts "METHOD|#{key}|#{grouped[key].map { |r| r.join(':') }.join(' -> ')}" }
    when 'order'
      entries.drop(1).each do |e|
        name = filename(e[:name]).sub(/\.rb\z/, '')
        name = '~blank' if name.empty?
        name += '~blank' if e[:source].empty? && !name.end_with?('~blank')
        puts name
      end
    when 'headers'
      entries.select { |e| e[:index] >= 120 && !e[:source].strip.empty? }.each do |e|
        puts "SCRIPT|#{e[:index]}|#{e[:name]}|active=#{e[:active]}|export=#{e[:export]}"
        e[:headers].first(7).each { |h| puts "  #{h[:line]}: #{h[:text]}" }
      end
    when 'differences'
      entries.select { |e| e[:export] == 'different' }.each do |e|
        puts "SCRIPT|#{e[:index]}|#{e[:name]}"
        a = e[:source].gsub(/\r\n?/, "\n").lines
        b = File.read(e[:path], encoding: 'UTF-8').gsub(/\r\n?/, "\n").lines
        (0...[a.length, b.length].max).select { |n| a[n] != b[n] }.first(8).each do |n|
          puts "  L#{n + 1} runtime=#{a[n].inspect} export=#{b[n].inspect}"
        end
      end
    when 'json'
      puts JSON.pretty_generate(entries.map { |e| e.reject { |k, _| [:source, :path].include?(k) } })
    else
      entries.reject { |e| e[:source].empty? }.each do |e|
        puts "SCRIPT|#{e[:index]}|#{e[:name]}|active=#{e[:active]}|export=#{e[:export]}|syntax=#{e[:syntax]}"
      end
      puts "TOTAL|slots=#{entries.length}|active=#{entries.count { |e| e[:active] }}|different=#{entries.count { |e| e[:export] == 'different' }}"
    end
  end
end

ScriptInventory.run if $PROGRAM_NAME == __FILE__
