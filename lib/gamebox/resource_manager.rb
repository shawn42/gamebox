#!/usr/bin/env ruby
$: << "#{File.dirname(__FILE__)}/../config"
require "fileutils"
require 'inflector'

class ResourceManager
  def initialize
    @loaded_images = {}
    @loaded_fonts = {}
  end

  def load_animation_set(actor, action)
    # use pngs only for now
    actor_dir = Inflector.underscore(actor.class)
    gfx_path = DATA_PATH+"graphics/"
    frames = Dir.glob("#{gfx_path}#{actor_dir}/#{action}/*.png")
    action_imgs = []

    frames = frames.sort_by {|f| File.basename(f).to_i }
    
    for frame in frames
      rel_path = frame.slice(gfx_path.size,frame.size)
      action_imgs << load_image(rel_path)
    end
    action_imgs
  end

  def load_image(file_name)
    cached_img = @loaded_images[file_name]
    if cached_img.nil?
      cached_img = Rubygame::Surface.load(File.expand_path(DATA_PATH + "graphics/" + file_name))
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
    end
  end

  def load_sound(full_name)
    begin
      sound = Rubygame::Sound.load(full_name)
      return sound
    rescue Rubygame::SDLError => ex
      puts "Cannot load sound " + full_name + " : " + ex
    end
  end

  # loads TTF fonts from the fonts dir and caches them for later
  def load_font(name, size)
    @loaded_fonts[name] ||= {}
    return @loaded_fonts[name][size] if @loaded_fonts[name][size]
    begin
      unless @ttf_loaded
        TTF.setup
        @ttf_loaded = true
      end
      
      full_name = File.expand_path(DATA_PATH + "fonts/" + name)
      font = TTF.new(full_name, size)
      @loaded_fonts[name][size] = font
      return font
    rescue Exception => ex
      puts "Cannot load font " + full_name + " : " + ex
    end
    return nil
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
