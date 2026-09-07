# frozen_string_literal: true

# Materialize one logical document from GAME_SCRIPT_AI_COMPACT_V2.md.
# Usage:
#   ruby tools/compact_script_expand.rb "Route Máy Pha Cà Phê"

path = File.expand_path("../docs/kich ban/GAME_SCRIPT_AI_COMPACT_V2.md", __dir__)
title = ARGV.join(" ").strip
abort "Usage: ruby tools/compact_script_expand.rb ROUTE_TITLE" if title.empty?

lines = File.readlines(path, encoding: "UTF-8", chomp: true)
heading = "### #{title}"
start = lines.index(heading)
abort "Route not found: #{title}" unless start

main = lines[(start + 1)..].find { |line| line.start_with?("MAIN: ") }
abort "MAIN sequence not found for: #{title}" unless main

registry = {}
lines.each do |line|
  match = /\A(B\d{4}):\s?(.*)\z/.match(line)
  registry[match[1]] = match[2] if match
end

ids = main.delete_prefix("MAIN: ").split.flat_map do |token|
  if (range = /\AB(\d{4})\.\.B(\d{4})\z/.match(token))
    (range[1].to_i..range[2].to_i).map { |id| format("B%04d", id) }
  elsif token.match?(/\AB\d{4}\z/)
    token
  else
    abort "Invalid MAIN token: #{token}"
  end
end

missing = ids.reject { |id| registry.key?(id) }.uniq
abort "Missing registry blocks: #{missing.join(', ')}" unless missing.empty?

puts "# #{title} — expanded from AI Compact"
puts
ids.each { |id| puts registry.fetch(id) }

