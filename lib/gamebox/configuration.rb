module Gamebox
  # Returns the global configuration object
  def self.configuration
    @configuration ||= Configuration.new
  end

  # Pattern stolen from rspec for configuration
  class Configuration
    def self.add_setting(name, opts={})
      if opts[:alias]
        alias_method name, opts[:alias]
        alias_method "#{name}=", "#{opts[:alias]}="
        alias_method "#{name}?", "#{opts[:alias]}?"
      else
        define_method("#{name}=") {|val| settings[name] = val}
        define_method(name)       { settings.has_key?(name) ? settings[name] : opts[:default] }
        define_method("#{name}?") { send name }
      end
    end

    add_setting :config_path
    add_setting :music_path
    add_setting :sound_path
    # add_setting :output, :alias => :output_stream

    def settings
      @settings ||= {}
    end
  end
end
