require 'gamebox/lib/platform'
require "erb"

desc "Run the game"
task :run do |t|
  sh "bundle exec ruby #{APP_ROOT}src/app.rb"
end
task :default => :run

desc "Report code statistics (KLOCs, etc) from the application"
task :stats do
  require 'gamebox/lib/code_statistics'
  CodeStatistics.new(*STATS_DIRECTORIES).to_s
end


desc "Run the game with debug server"
task :debug do |t|
  sh "bundle exec ruby #{APP_ROOT}src/app.rb -debug-server"
end

desc "Bundle in all required gems"
task :bundle do |t|
  sh "bundle package"
  sh "bundle install vendor/bundle --disable-shared-gems"
end

desc "Run specs"
task :spec do
  begin
    require 'rspec/core/rake_task'

    RSpec::Core::RakeTask.new(:specz) do |t|
      # t.pattern = "./spec/**/*_spec.rb" # don't need this, it's default.
      # Put spec opts in a file named .rspec in root
    end
    Rake::Task[:specz].execute
  rescue LoadError
    puts "warning: rspec not installed"
    puts "install with gem install rspec"
  end
end

namespace :generate do
  #didnt't use pluralize in here because I didnt want to include all of active support just for pluralize
  [:actor, :stage, :behavior].each do |generator_name|
    desc "generate a new #{generator_name} in the #{ generator_name }s folder"
    task generator_name, "#{generator_name}_name".to_sym do |t, args|
      File.open(File.join(File.dirname(__FILE__), "../../..", "/templates/#{generator_name}_template.erb")) do |io|
        template = ERB.new io.read
        instance_variable_set("@#{generator_name}_name", args["#{generator_name}_name"])
        File.open "#{APP_ROOT}src/#{ generator_name}s/#{args["#{generator_name}_name"]}.rb", "w" do |out|
          out.puts template.result binding
        end
      end
    end
  end
end

