class ConfigManager

  def settings
    @settings ||= base_configuration.merge(user_configuration)
  end

  def [](key)
    settings[key]
  end

  def []=(key,val)
    settings[key] = val
  end


  def game_settings_file
    "game.yml"
  end

  def user_configuration_directory
    File.join(ENV['HOME'], ".gamebox")
  end

  def base_configuration_directory
    Gamebox.configuration.config_path
  end

  def user_configuration_filepath
    File.join(user_configuration_directory, game_settings_file)
  end

  def base_configuration_filepath
    File.join(base_configuration_directory, game_settings_file)
  end

  def base_configuration
    load base_configuration_filepath
  end

  def user_configuration
    load user_configuration_filepath
  end

  def load(configuration_filepath)
    File.exist?(configuration_filepath) ? YAML::load_file(configuration_filepath) : {}
  end

  def save
    save_to_file(user_configuration_filepath,settings.to_yaml)
  end

  def save_to_file(filepath,settings)
    FileUtils.mkdir_p File.dirname(filepath)
    File.write(filepath,settings)
  end

end
