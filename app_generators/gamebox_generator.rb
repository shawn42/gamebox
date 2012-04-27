require 'rbconfig'

class GameboxGenerator < RubiGen::Base
  DEFAULT_SHEBANG = File.join(RbConfig::CONFIG['bindir'],
                              RbConfig::CONFIG['ruby_install_name'])

  default_options   :shebang => DEFAULT_SHEBANG

  attr_reader :app_name, :module_name

  def initialize(runtime_args, runtime_options = {})
    super
    usage if args.empty?
    @destination_root = args.shift
    @app_name     = File.basename(File.expand_path(@destination_root))
    @module_name  = app_name.camelize
    extract_options
  end

  def manifest
    # Use /usr/bin/env if no special shebang was specified
    script_options     = { :chmod => 0755, :shebang => options[:shebang] == DEFAULT_SHEBANG ? nil : options[:shebang] }
    windows            = (RUBY_PLATFORM =~ /dos|win32|cygwin/i) || (RUBY_PLATFORM =~ /(:?mswin|mingw)/)

    record do |m|
      # Root directory and all subdirectories.
      m.directory ''
      BASEDIRS.each { |path| m.directory path }

      # Root
      m.template_copy_each %w( Rakefile 
                               README.rdoc 
                               config/environment.rb
                             )

      m.file_copy_each     %w( 
                               Gemfile
                               config/boot.rb
                               config/game.yml
                               config/stage_config.yml

                               data/fonts/FONTS_GO_HERE
                               data/graphics/GRAPHICS_GO_HERE
                               data/music/MUSIC_GOES_HERE
                               data/sounds/SOUND_FX_GO_HERE
                              
                               spec/helper.rb

                               src/app.rb
                               src/demo_stage.rb
                               src/my_actor.rb
                             )

      m.readme 'NEXT_STEPS.txt'

      # Scripts
      # %w( generate ).each do |file|
      #   m.template "script/#{file}",        "script/#{file}", script_options
      #   # m.template "script/win_script.cmd", "script/#{file}.cmd", 
      #   #   :assigns => { :filename => file } if windows
      # end

    end
  end

  protected
    def banner
      <<-EOS
Create a stub for a gamebox game.

Usage: gamebox /path/to/your/app [options]"
EOS
    end

    def add_options!(opts)
      opts.separator ''
      opts.separator "Gamebox options:"
      opts.on("-v", "--version", "Show the #{File.basename($0)} version number.")
    end

    def extract_options
    end

  # Installation skeleton.  Intermediate directories are automatically
  # created so don't sweat their absence here.
  BASEDIRS = %w(
    src
    spec
    data/fonts
    data/graphics
    data/music
    data/sounds
    config
  )
end

