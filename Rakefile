begin
  require 'jeweler'
  require File.dirname(__FILE__)+'/lib/gamebox/version'
  Jeweler::Tasks.new do |gem|
    gem.name = "gamebox"
    gem.executables = "gamebox"
    gem.rubyforge_project = "gamebox"
    gem.summary = %Q{Framework for building and distributing games using Rubygame}
    gem.description = %Q{Framework for building and distributing games using Rubygame}
    gem.email = "shawn42@gmail.com"
    gem.homepage = "http://shawn42.github.com/gamebox"
    gem.authors = ["Shawn Anderson","Jason Roelofs","Karlin Fox"]
    gem.add_development_dependency "rspec"
    gem.add_development_dependency "jeweler"
    gem.add_dependency 'constructor'
    gem.add_dependency 'publisher'
    gem.files.exclude 'examples'
    gem.test_files = FileList['{spec,test}/**/*.rb']
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
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
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = FileList['spec/*_spec.rb']
end
task :default => :spec

desc "Run rcov rspecs"
Spec::Rake::SpecTask.new('rcov_rspec') do |t|
  t.spec_files = FileList['spec/*_spec.rb']
  t.rcov = true
  t.rcov_opts = ['--exclude', 'examples']
end

# vim: syntax=Ruby
