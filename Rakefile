require 'bundler'
Bundler::GemHelper.install_tasks
begin
  require 'metric_fu'
rescue LoadError
  puts "metric_fu (or a dependency) not available. Install it with: sudo gem install metric_fu"
end

STATS_DIRECTORIES = [
  %w(Source         lib/),
  %w(Unit\ tests         spec/)
].collect { |name, dir| [ name, "#{dir}" ] }.select { |name, dir| File.directory?(dir) }

desc "Report code statistics (KLOCs, etc) from the application"
task :stats do
  require 'code_statistics'
  CodeStatistics.new(*STATS_DIRECTORIES).to_s
end

begin
  require 'rspec/core/rake_task'
  desc "Run all rspecs"
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.pattern = 'spec/**/*_spec.rb'
  end

  desc "Run all specs with rcov"
  RSpec::Core::RakeTask.new(:rcov) do |t|
      t.rcov = true
  end

  task :default => :spec
rescue LoadError
  puts "please install rspec to run tests"
  puts "install with gem install rspec"
end



# vim: syntax=Ruby
