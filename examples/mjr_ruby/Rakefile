libdir = File.dirname(__FILE__)+"/lib"
$: << libdir
confdir = File.dirname(__FILE__)+"/config"
$: << confdir

require 'environment'
require 'gamebox/tasks/gamebox_tasks'
STATS_DIRECTORIES = [
  %w(Source            src/), 
  %w(Config            config/), 
  %w(Maps              maps/), 
  %w(Unit\ tests       specs/),
  %w(Libraries         lib/),
].collect { |name, dir| [ name, "#{APP_ROOT}/#{dir}" ] }.select { |name, dir| File.directory?(dir) }

desc "Report code statistics (KLOCs, etc) from the application"
task :stats do
  require 'code_statistics'
  CodeStatistics.new(*STATS_DIRECTORIES).to_s
end

require 'spec/rake/spectask'
desc "Run all specs"
Spec::Rake::SpecTask.new('specs') do |t|
  t.spec_opts = ["-r", "./test/helper"]
  t.spec_files = FileList['test//test_*.rb']
end
task :test => :specs
