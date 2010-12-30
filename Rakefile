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
rescue LoadError
  puts "please install rspec to run tests"
  puts "install with gem install rspec"
end

# vim: syntax=Ruby
