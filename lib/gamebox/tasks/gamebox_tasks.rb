require 'gamebox/lib/platform'
require 'spec/rake/spectask'

task :default => :run
desc "Run the game"
task :run do |t|
  if Platform.mac?                                               
    sh "rsdl src/app.rb"                                          
  else
    sh "ruby src/app.rb"                                         
  end
end 

desc "Report code statistics (KLOCs, etc) from the application"
task :stats do
  require 'gamebox/lib/code_statistics'
  CodeStatistics.new(*STATS_DIRECTORIES).to_s
end


desc "Run the game with debug server"
task :debug do |t|
  if Platform.mac?                                               
    sh "rsdl src/app.rb -debug-server"                                          
  else
    sh "ruby src/app.rb -debug-server"                                         
  end
end

require 'spec/rake/spectask'
desc "Run all specs"
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_opts = ["-r", "./spec/helper"]
  t.spec_files = FileList['spec//*_spec.rb']
end
task :rspec => :spec
task :test => :spec
