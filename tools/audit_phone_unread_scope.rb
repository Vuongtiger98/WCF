# Read-only proof of script identity, map preservation and native QA inputs.
require 'json'
require 'digest'
require 'zlib'
root=File.expand_path('..',__dir__)
backup=File.join(root,'Data/codex_backup_phone_unread_20261116')
old=Marshal.load(File.binread(File.join(backup,'Scripts.rvdata2')))
now=Marshal.load(File.binread(File.join(root,'Data/Scripts.rvdata2')))
raise 'Slot count changed' unless old.size==now.size
changed=[]
old.zip(now).each do |a,b|
  raise 'Script identity/order changed' unless a[0,2]==b[0,2]
  changed << b[1] if a[2]!=b[2]
end
raise "Unexpected changes #{changed}" unless changed.sort==['Custom Menu','Cutscene Group Chat','WCF Test Hub'].sort
raise 'CSV changed' unless File.binread(File.join(backup,'!script_order.csv'))==File.binread(File.join(root,'Scripts/!script_order.csv'))
manifest=JSON.parse(File.read(File.join(backup,'data-sha256.json')))
manifest.each {|path,sha|raise "Data changed #{path}" unless Digest::SHA256.file(File.join(root,path)).hexdigest==sha}
before=File.read(File.join(backup,'Cutscene Group Chat.rb')).gsub("\r\n","\n")
after=File.read(File.join(root,'Scripts/Cutscene Group Chat.rb')).gsub("\r\n","\n")
raise 'Authored preset dialogue/choices changed' unless before[before.index('module GroupChatPreset')..-1]==after[after.index('module GroupChatPreset')..-1]
puts "PHONE_UNREAD_SCOPE|slots=#{now.size}|changed=#{changed.join(',')}|data_files=#{manifest.size}|maps_preserved=true|preset_text_preserved=true|order_preserved=true"
