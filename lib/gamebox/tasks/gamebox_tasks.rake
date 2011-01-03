require 'gamebox/lib/platform'

desc "Run the game"
task :run do |t|
  sh "bundle exec ruby src/app.rb"
end 
task :default => :run

desc "Report code statistics (KLOCs, etc) from the application"
task :stats do
  require 'gamebox/lib/code_statistics'
  CodeStatistics.new(*STATS_DIRECTORIES).to_s
end


desc "Run the game with debug server"
task :debug do |t|
  sh "ruby src/app.rb -debug-server"                                         
end

desc "Bundle in all required gems"
task :bundle do |t|
  sh "bundle package"
  sh "bundle install vendor/bundle --disable-shared-gems"
end

begin
  require 'spec/rake/spectask'
  desc "Run all specs"
  Spec::Rake::SpecTask.new('spec') do |t|
    t.spec_opts = ["-r", "./spec/helper"]
    t.spec_files = FileList['spec//*_spec.rb']
  end
  task :rspec => :spec
  task :test => :spec
rescue LoadError
  puts "warning: rspec not installed"
  puts "install with gem install rspec"
end

namespace :dist do
  task :vendor do
    sh 'wget http://github.com/downloads/shawn42/gamebox/vendor.zip; unzip vendor.zip; rm vendor.zip'
  end
  task :win do
    # create dist dir
    FileUtils.mkdir "dist" unless File.exist? "dist"
    # pull down windows app shell
    # expand into place
    sh 'cd dist; wget http://github.com/downloads/shawn42/gamebox/gamebox_app.zip; unzip gamebox_app.zip; mv gamebox_app/* .; rm gamebox_app.zip; rm -rf gamebox_app'

    # copy config/src/lib/data into dist/src
    %w{vendor config data }.each do |dir|
      FileUtils.cp_r dir, File.join('dist','src', dir) if File.exist? dir
    end
    FileUtils.cp_r 'src', File.join('dist', 'src')

    # create zip of dist?
  end
end

