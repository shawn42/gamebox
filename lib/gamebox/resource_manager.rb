#!/usr/bin/env ruby
$: << "#{File.dirname(__FILE__)}/../config"
require "fileutils"

class ResourceManager
  def initialize
    @loaded_images = {}
    @loaded_svgs = {}
  end

  def load_image(file_name)
    cached_img = @loaded_images[file_name]
    if cached_img.nil?
      cached_img = Rubygame::Surface.load(File.expand_path(DATA_PATH + "gfx/" + file_name))
      @loaded_images[file_name] = cached_img
    end
    cached_img
  end

  def load_music(full_name)
    begin
      sound = Rubygame::Music.load(full_name)
      return sound
    rescue Rubygame::SDLError => ex
      puts "Cannot load music " + full_name + " : " + ex
      exit
    end
  end

  def load_sound(name)
    begin
      full_name = File.expand_path(DATA_PATH + "sound/" + name)
      sound = Rubygame::Sound.load(full_name)
      return sound
    rescue Rubygame::SDLError => ex
      puts "Cannot load sound " + full_name + " : " + ex
      exit
    end
  end

  # TODO make this path include that app name?
  def load_config(name)
    conf = YAML::load_file(CONFIG_PATH + name + ".yml")
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
