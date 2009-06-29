require 'rubygems'
gem 'hoe', '>= 2.3.0'
require 'hoe'

module Gamebox
  VERSION = '0.0.5'
end
Hoe.new 'gamebox' do |spec|
  spec.developer('Shawn Anderson', 'shawn42@gmail.com')
  spec.author = "Shawn Anderson"
  spec.description = "Framework for building and distributing games using Rubygame"
  spec.email = 'shawn42@gmail.com'
  spec.summary = "Framework for building and distributing games using Rubygame"
  spec.url = "http://shawn42.github.com/gamebox"
  spec.version = Gamebox::VERSION
  spec.changes = spec.paragraphs_of('History.txt', 8..9).join("\n\n")
  spec.extra_deps << ['constructor']
  spec.extra_deps << ['publisher']
  spec.extra_deps << ['bacon']
  if spec.extra_rdoc_files
    spec.extra_rdoc_files << 'docs/getting_started.rdoc' 
  end
  spec.remote_rdoc_dir = ' ' # Release to root
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

task :test => :bacon

# vim: syntax=Ruby
