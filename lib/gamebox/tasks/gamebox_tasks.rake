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
        File.open "#{APP_ROOT}src/#{ generator_name}s/#{args["#{generator_name}_name"]}_#{generator_name}.rb", "w" do |out|
          out.puts template.result binding
        end
      end
    end
  end
end

namespace :dist do
  desc "Build a .app for your gamebox game"
  task :mac do
    GAME_NAME = "UntitledGame" unless defined?(GAME_NAME)
    # DL template os x app
    remote_file = "gosu-mac-wrapper-#{Gosu::VERSION}.tar.gz"
    mac_build = "#{APP_ROOT}build/mac"
    local_file = "#{mac_build}/#{remote_file}"

    require 'net/http'
    mkdir_p mac_build
    # if false
      Net::HTTP.start("www.libgosu.org") do |http|
        resp = http.get("/downloads/#{remote_file}")
        open(local_file, "wb") { |file| file.write(resp.body) }
      end
    # end

    # Expand it
    cd mac_build
    `tar xzf #{remote_file}`
    app_name = "#{GAME_NAME}.app"
    contents = "#{app_name}/Contents"
    resources = "#{contents}/Resources"
    dot_app_lib = "#{resources}/lib"
    gem_vendored = "#{mac_build}/#{resources}/gems"

    mv 'RubyGosu App.app', app_name
    %w(config data src).each do |src|
      cp_r "../../#{src}", resources
    end

    # TODO remove chingu / chipmunk / etc
    clean_em_out = %w(chingu chingu.rb).map{|it| "#{dot_app_lib}/#{it}"}
    rm_rf clean_em_out#, :verbose => true, :noop => true

    cd APP_ROOT
    p `bundle --system package`
    p `bundle package`
    p `bundle --deployment`
    mkdir_p gem_vendored
    rejects = %w(chipmunk gosu)
    Dir["vendor/bundle/ruby/**/gems/**/lib"].each do |gemmy|
      cp_r gemmy, gem_vendored unless rejects.any?{|exclude| gemmy.match exclude}
    end

    cd mac_build
    File.open "#{resources}/Main.rb", "w+" do |main|
      main.puts <<-EOS
      $: << "\#{File.dirname(__FILE__)}/config"

      $: << "\#{File.dirname(__FILE__)}/gems/lib"

      rejects = %w(spec src/app.rb vendor Main.rb)
      ok_dirs = %w(config gems src)
      REQUIRE_ALLS = ok_dirs.map{|dir| Dir.glob("\#{dir}/*.rb").reject{ |f| rejects.any?{|exclude| f.match exclude}}}.flatten

      require 'environment'

      GameboxApp.run ARGV, ENV
      EOS
    end

    # modify plist file
    # UntitledGame
    cd "#{GAME_NAME}.app/Contents"
    plist = File.open("Info.plist").read
    File.open("Info.plist", 'w+') do |f|
      f.puts plist.gsub "UntitledGame", GAME_NAME
    end
  end

  task :win do
    # create dist dir
    FileUtils.mkdir "#{APP_ROOT}dist" unless File.exist? "dist"
    # pull down windows app shell
    # expand into place
    sh 'cd #{APP_ROOT}dist; wget http://github.com/downloads/shawn42/gamebox/gamebox_app.zip; unzip gamebox_app.zip; mv gamebox_app/* .; rm gamebox_app.zip; rm -rf gamebox_app'

    # copy config/src/lib/data into dist/src
    %w{vendor config data }.each do |dir|
      FileUtils.cp_r dir, File.join('dist','src', dir) if File.exist? dir
    end
    FileUtils.cp_r 'src', File.join('dist', 'src')

    # create zip of dist?
  end
end

