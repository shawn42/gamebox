require 'rbconfig'
require File.dirname(__FILE__) + '/template_runner'

class AppGenerator < Gamebox::Generator::Base
  DEFAULT_SHEBANG = File.join(Config::CONFIG['bindir'], Config::CONFIG['ruby_install_name'])

  mandatory_options :source => "#{File.dirname(__FILE__)}/../../../../template_app"
  default_options   :shebang => DEFAULT_SHEBANG

  def initialize(runtime_args, runtime_options = {})
    super

    usage if args.empty?

    @destination_root = args.shift
    @app_name = File.basename(File.expand_path(@destination_root))
  end

  def manifest
    record do |m|
      create_directories(m)
      create_root_files(m)
      create_app_files(m)
      create_config_files(m)
      create_lib_files(m)
#      create_script_files(m)
#      create_test_files(m)
      create_documentation_file(m)
    end
  end

  def after_generate
    if options[:template]
      Gamebox::TemplateRunner.new(options[:template], @destination_root)
    end
  end

  protected
    def banner
      "Usage: #{$0} /path/to/your/app [options]"
    end

    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("-r", "--ruby=path", String,
             "Path to the Ruby binary of your choice (otherwise scripts use env, dispatchers current path).",
             "Default: #{DEFAULT_SHEBANG}") { |v| options[:shebang] = v }

      opt.on("-m", "--template=path", String,
            "Use an application template that lives at path (can be a filesystem path or URL).",
            "Default: (none)") { |v| options[:template] = v }

    end


  private
    def create_directories(m)
      m.directory ''

      # Intermediate directories are automatically created so don't sweat their absence here.
      %w(
        src
        config
        data
        doc
        lib
        lib/tasks
        log
        script
        test
        vendor
      ).each { |path| m.directory(path) }
    end
    
    def create_root_files(m)
      m.file "Rakefile", "Rakefile"
      m.file "README",         "README"
    end
    
    def create_app_files(m)
      m.file "src/app.rb", "src/app.rb"
      m.file "src/game.rb", "src/game.rb"
      m.file "src/config_manager.rb", "src/config_manager.rb"
      m.file "src/input_manager.rb", "src/input_manager.rb"
      m.file "src/resource_manager.rb", "src/resource_manager.rb"
      m.file "src/wrapped_screen.rb", "src/wrapped_screen.rb"
    end

    def create_config_files(m)
#      create_initializer_files(m)
      create_environment_files(m)
    end

    def create_documentation_file(m)
      m.file "doc/README_FOR_APP", "doc/README_FOR_APP"
    end

    def create_lib_files(m)
      m.file "lib/code_statistics.rb", "lib/code_statistics.rb"
      m.file "lib/diy.rb", "lib/diy.rb"
      m.file "lib/inflections.rb", "lib/inflections.rb"
      m.file "lib/inflector.rb", "lib/inflector.rb"
      m.file "lib/platform.rb", "lib/platform.rb"
    end

    def create_script_files(m)
      %w( 
        about console dbconsole destroy generate runner server plugin
        performance/benchmarker performance/profiler
      ).each do |file|
        m.file "bin/#{file}", "script/#{file}", { 
          :chmod => 0755, 
          :shebang => options[:shebang] == DEFAULT_SHEBANG ? nil : options[:shebang]
        }
      end
    end

    def create_initializer_files(m)
      %w( 
        backtrace_silencers 
        inflections 
        mime_types 
        new_rails_defaults
      ).each do |initializer|
        m.file "configs/initializers/#{initializer}.rb", "config/initializers/#{initializer}.rb"
      end

      m.template "configs/initializers/session_store.rb", "config/initializers/session_store.rb", 
        :assigns => { :app_name => @app_name, :app_secret => ActiveSupport::SecureRandom.hex(64) }
    end

    def create_environment_files(m)
      m.template "config/environment.rb", "config/environment.rb", 
        :assigns => { :freeze => options[:freeze] }

      m.file "config/boot.rb",        "config/boot.rb"
    end

    def mysql_socket_location
      [
        "/tmp/mysql.sock",                        # default
        "/var/run/mysqld/mysqld.sock",            # debian/gentoo
        "/var/tmp/mysql.sock",                    # freebsd
        "/var/lib/mysql/mysql.sock",              # fedora
        "/opt/local/lib/mysql/mysql.sock",        # fedora
        "/opt/local/var/run/mysqld/mysqld.sock",  # mac + darwinports + mysql
        "/opt/local/var/run/mysql4/mysqld.sock",  # mac + darwinports + mysql4
        "/opt/local/var/run/mysql5/mysqld.sock",  # mac + darwinports + mysql5
        "/opt/lampp/var/mysql/mysql.sock"         # xampp for linux
      ].find { |f| File.exist?(f) } unless RUBY_PLATFORM =~ /(:?mswin|mingw)/
    end
end
