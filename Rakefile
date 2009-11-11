require 'rubygems'
gem 'hoe', '>= 2.3.0'
require 'hoe'

require File.dirname(__FILE__)+'/lib/gamebox/version'
Hoe.spec 'gamebox' do
  developer('Shawn Anderson', 'shawn42@gmail.com')
  developer('Jason Roelofs', 'jameskilton@gmail.com')
  developer('Karlin Fox', 'karlin.fox@gmail.com')
  description = "Framework for building and distributing games using Rubygame"
  email = 'shawn42@gmail.com'
  summary = "Framework for building and distributing games using Rubygame"
  url = "http://shawn42.github.com/gamebox"
  self.version = Gamebox::VERSION::STRING
  changes = paragraphs_of('History.txt', 12..13).join("\n\n")
  extra_deps << ['constructor']
  extra_deps << ['publisher']
  extra_deps << ['rspec']
  if extra_rdoc_files
    extra_rdoc_files << 'docs/getting_started.rdoc' 
  end
  remote_rdoc_dir = ' ' # Release to root
end

STATS_DIRECTORIES = [
  %w(Source         lib/)
].collect { |name, dir| [ name, "#{dir}" ] }.select { |name, dir| File.directory?(dir) }

desc "Report code statistics (KLOCs, etc) from the application"
task :stats do
  require 'code_statistics'
  CodeStatistics.new(*STATS_DIRECTORIES).to_s
end

require 'spec/rake/spectask'
desc "Run all rspecs"
Spec::Rake::SpecTask.new('rspec') do |t|
  t.spec_files = FileList['spec/*_spec.rb']
end
task :default => :rspec

# vim: syntax=Ruby
