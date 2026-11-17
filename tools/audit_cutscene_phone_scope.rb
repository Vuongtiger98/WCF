# Read-only scope check against the snapshot before the chat UI migration.
require 'zlib'
require 'digest'
root=File.expand_path('..',__dir__)
backup=File.join(root,'Data/codex_backup_cutscene_chat_20261116')
old=Marshal.load(File.binread(File.join(backup,'Scripts.rvdata2')))
now=Marshal.load(File.binread(File.join(root,'Data/Scripts.rvdata2')))
raise 'Script slot count changed' unless old.size==now.size
changed=[]
old.zip(now).each do |a,b|
  raise 'Script identity/order changed' unless a[0,2]==b[0,2]
  changed << b[1] unless a[2]==b[2]
end
raise "Unexpected script changes #{changed}" unless changed.sort==['Custom Menu','Cutscene Group Chat'].sort
%w[!script_order.csv].each do |name|
  raise 'CSV changed' unless File.binread(File.join(backup,name))==File.binread(File.join(root,'Scripts',name))
end
%w[Map003.rvdata2 Map010.rvdata2 Map069.rvdata2 System.rvdata2].each do |name|
  raise "Unexpected data edit #{name}" unless File.binread(File.join(backup,name))==File.binread(File.join(root,'Data',name))
end
before=File.read(File.join(backup,'Cutscene Group Chat.rb'),encoding:'UTF-8').gsub("\r\n","\n")
after=File.read(File.join(root,'Scripts/Cutscene Group Chat.rb'),encoding:'UTF-8').gsub("\r\n","\n")
raise 'Preset dialogue/branch changed' unless before[before.index('module GroupChatPreset')..-1]==after[after.index('module GroupChatPreset')..-1]
segment=lambda {|s|s[s.index('class Game_Temp')...s.index('module GroupChat')]}
raise 'Chat data/API changed' unless segment.call(before)==segment.call(after)
puts "CUTSCENE_CHAT_SCOPE|slots=#{now.size}|changed=#{changed.join(',')}|order_preserved=true|presets_unchanged=true|chat_data_unchanged=true|maps_unchanged=true"
