class ConfigManager

  attr_accessor :settings
  constructor :resource_manager
  GAME_SETTINGS_FILE = "game"

  def setup()
    @settings = @resource_manager.load_config(GAME_SETTINGS_FILE)
  end

  def save()
    @resource_manager.save_settings(GAME_SETTINGS_FILE, @settings)
  end

  def [](key)
    @settings[key]
  end

  def []=(key,val)
    @settings[key] = val
  end
end
