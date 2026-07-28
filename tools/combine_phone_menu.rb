require "fileutils"
require "zlib"

ROOT = File.expand_path("..", __dir__)
SCRIPTS_DIR = File.join(ROOT, "Scripts")
DATA_FILE = File.join(ROOT, "Data", "Scripts.rvdata2")

base_path = File.join(SCRIPTS_DIR, "Custom Menu.rb")
gallery_path = File.join(SCRIPTS_DIR, "Phone Menu Gallery Upgrade.rb")
chat_patch_path = File.join(SCRIPTS_DIR, "Phone Menu Group Chat Save Patch.rb")
cutscene_path = File.join(SCRIPTS_DIR, "Cutscene Group Chat.rb")

[base_path, gallery_path, chat_patch_path, cutscene_path, DATA_FILE].each do |path|
  raise "Missing required file: #{path}" unless File.file?(path)
end

base = File.binread(base_path)
gallery = File.binread(gallery_path)
chat_patch = File.binread(chat_patch_path)
cutscene = File.binread(cutscene_path)

# The gallery upgrade replaces this entire legacy block. Keeping both versions
# only wastes memory and makes the effective implementation depend on load order.
legacy_start = base.index("  # Gallery\r\n") || base.index("  # Gallery\n")
dispose_start = base.index("  # Dispose\r\n", legacy_start || 0) ||
                base.index("  # Dispose\n", legacy_start || 0)
raise "Could not locate legacy gallery block" unless legacy_start && dispose_start
base = base.byteslice(0, legacy_start) + base.byteslice(dispose_start, base.bytesize)

banner = <<~RUBY

  #==============================================================================
  # ** Unified Phone Menu
  #------------------------------------------------------------------------------
  # Custom phone menu + global/gallery upgrade + saved group-chat integration.
  # Generated from the three previously separate scripts.
  #==============================================================================

RUBY
unified = base.rstrip + banner + gallery.strip + "\n\n" + chat_patch.strip + "\n"

stamp = Time.now.strftime("%Y%m%d-%H%M%S")
backup_dir = File.join(ROOT, "Data", "codex_backup_phone_menu_#{stamp}")
FileUtils.mkdir_p(backup_dir)
FileUtils.cp(DATA_FILE, File.join(backup_dir, "Scripts.rvdata2"), preserve: true)
[base_path, gallery_path, chat_patch_path].each do |path|
  FileUtils.cp(path, File.join(backup_dir, File.basename(path)), preserve: true)
end

# Keep the readable mirror in sync with the actual runtime script.
File.binwrite(base_path, unified)
FileUtils.rm_f(gallery_path)
FileUtils.rm_f(chat_patch_path)

slots = Marshal.load(File.binread(DATA_FILE))
find_slot = lambda do |name|
  slots.index { |entry| entry[1].to_s.strip == name }
end

custom_i = find_slot.call("Custom Menu")
gallery_i = find_slot.call("Phone Menu Gallery Upgrade")
cutscene_i = find_slot.call("Cutscene Group Chat")
chat_patch_i = find_slot.call("Phone Menu Group Chat Save Patch")
raise "Could not locate all phone-menu runtime slots" unless [custom_i, gallery_i, cutscene_i, chat_patch_i].all?

# The saved-chat integration must load after Cutscene Group Chat. Put the
# dependency first and the unified menu immediately after it, before exporter.
slots[custom_i][1] = "Cutscene Group Chat"
slots[custom_i][2] = Zlib::Deflate.deflate(cutscene)
slots[gallery_i][1] = "Custom Menu"
slots[gallery_i][2] = Zlib::Deflate.deflate(unified)

[cutscene_i, chat_patch_i].each do |index|
  slots[index][1] = ""
  slots[index][2] = Zlib::Deflate.deflate("")
end

File.binwrite(DATA_FILE, Marshal.dump(slots))

# Rebuild export order so a later mode-1 export preserves the new layout.
order = slots.drop(1).map do |entry|
  name = entry[1].to_s
  name.empty? ? "~blank" : name.gsub("~", "~~")
end
File.binwrite(File.join(SCRIPTS_DIR, "!script_order.csv"), order.join("\r\n") + "\r\n")

# Verify the written Marshal and compressed source, not just the source mirror.
verified = Marshal.load(File.binread(DATA_FILE))
runtime_source = Zlib::Inflate.inflate(verified[gallery_i][2])
raise "Runtime verification failed" unless runtime_source == unified
raise "Dependency order invalid" unless custom_i < gallery_i

puts "COMBINED|cutscene_slot=#{custom_i}|phone_slot=#{gallery_i}|bytes=#{unified.bytesize}"
puts "REMOVED_SLOTS|#{cutscene_i},#{chat_patch_i}"
puts "BACKUP|#{backup_dir}"
