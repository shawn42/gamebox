class ConfigManager

  attr_accessor :settings
  GAME_SETTINGS_FILE = "game"

  def initialize
    @settings = load_config(GAME_SETTINGS_FILE)
  end

  def save
    save_settings(GAME_SETTINGS_FILE, @settings)
  end

  def [](key)
    @settings[key]
  end

  def []=(key,val)
    @settings[key] = val
  end

  # TODO make this path include that app name?
  def load_config(name)
    conf = YAML::load_file("#{Gamebox.configuration.config_path}#{name}.yml")
    user_file = "#{ENV['HOME']}/.gamebox/#{name}.yml"
    if File.exist? user_file
      user_conf = YAML::load_file user_file
      conf = conf.merge user_conf
    end
    conf
  end

  def save_settings(name, settings)
    user_gamebox_dir = "#{ENV['HOME']}/.gamebox"
    FileUtils.mkdir_p user_gamebox_dir
    user_file = "#{ENV['HOME']}/.gamebox/#{name}.yml"
    File.open user_file, "w" do |f|
      f.write settings.to_yaml
    end
  end

end
