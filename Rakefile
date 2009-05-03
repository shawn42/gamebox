require 'rubygems'
require 'hoe'

module Gamebox
  VERSION = '0.0.1'
end
Hoe.new('gamebox', Gamebox::VERSION) do |p|
  p.developer('Shawn Anderson', 'shawn42@gmail.com')
  p.author = "Shawn Anderson"
  p.description = "Framework for building and distributing games using Rubygame"
  p.email = 'shawn42@gmail.com'
  p.summary = "Framework for building and distributing games using Rubygame"
  p.url = "http://shawn42.github.com/gamebox"
  p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")
  p.remote_rdoc_dir = '' # Release to root
  p.rdoc_pattern = /^(lib|bin|ext)|txt$|rdoc$/
  p.extra_deps << ['constructor']
  p.extra_deps << ['publisher']
  p.extra_deps << ['bacon']
end

STATS_DIRECTORIES = [
  %w(Source         lib/)
].collect { |name, dir| [ name, "#{dir}" ] }.select { |name, dir| File.directory?(dir) }

desc "Report code statistics (KLOCs, etc) from the application"
task :stats do
  require 'code_statistics'
  CodeStatistics.new(*STATS_DIRECTORIES).to_s
end

desc "Run all the strips of bacon"
task :bacon do
#  sh "bacon -Ilib:test --automatic --quiet"
  sh "bacon -Ilib:test --automatic "
end

# vim: syntax=Ruby
