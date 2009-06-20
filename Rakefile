require 'rubygems'
require 'hoe'

module Gamebox
  VERSION = '0.0.1'
end
Hoe.spec 'gamebox' do
  developer('Shawn Anderson', 'shawn42@gmail.com')
  author = "Shawn Anderson"
  description = "Framework for building and distributing games using Rubygame"
  email = 'shawn42@gmail.com'
  summary = "Framework for building and distributing games using Rubygame"
  url = "http://shawn42.github.com/gamebox"
  version = Gamebox::VERSION
  changes = paragraphs_of('History.txt', 0..1).join("\n\n")
  remote_rdoc_dir = '' # Release to root
  extra_deps << ['constructor']
  extra_deps << ['publisher']
  extra_deps << ['bacon']
  if extra_rdoc_files
    extra_rdoc_files << 'docs/getting_started.rdoc' 
  end
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
