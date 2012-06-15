module Gamebox
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
    add_setting :data_path
    add_setting :music_path
    add_setting :sound_path
    add_setting :gfx_path
    add_setting :fonts_path

    add_setting :gb_config_path
    add_setting :gb_data_path
    add_setting :gb_music_path
    add_setting :gb_sound_path
    add_setting :gb_gfx_path
    add_setting :gb_fonts_path
  
    add_setting :game_name, default: "Untitled Game"

    add_setting :stages, default: [:demo]

    def settings
      @settings ||= {}
    end
  end
end
