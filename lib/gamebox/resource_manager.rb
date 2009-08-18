#!/usr/bin/env ruby
$: << "#{File.dirname(__FILE__)}/../config"
require "fileutils"
require 'inflector'
require 'svg_document'

class ResourceManager
  def initialize
    @loaded_images = {}
    @loaded_fonts = {}
    @loaded_svgs = {}
  end

  def load_actor_image(actor)
    # use pngs only for now
    actor_name = Inflector.underscore(actor.class)
    return load_image("#{actor_name}.png")
  end

  def load_animation_set(actor, action)
    actor_dir = Inflector.underscore(actor.class)
    using_tileset = File.exist?("#{GFX_PATH}#{actor_dir}/#{action}.png")
    if using_tileset
      load_tile_set(actor, action)
    else
      load_frame_set(actor, action)
    end
  end

  #
  #         --------------- image from @path --------------
  # :right | [frame#1][frame#2][frame#3][frame#4][frame#5]|
  #         -----------------------------------------------
  #
  # :down  ---image----
  #       | [frame#1] |
  #       | [frame#2] |
  #       | [frame#3] |
  #       | [frame#4] |
  #       | [frame#5] |
  #       -------------
  #
  def load_tile_set(actor, action)
    actor_dir = Inflector.underscore(actor.class)
    tileset = load_image "#{actor_dir}/#{action}.png"

    action_imgs = []
    w,h = *tileset.size
    tileset.set_colorkey(tileset.get_at(0,0))

    if h > w
      # down
      num_frames = h/w
      clip_from = Rubygame::Rect.new(0, 0, w, w)
      clip_to = Rubygame::Rect.new(0, 0, w, w)
      num_frames.times do
        surface = Rubygame::Surface.new(clip_to.size)
        tileset.blit surface, clip_to, clip_from
        action_imgs << surface
        clip_from.y += w
      end
    else
      # right
      num_frames = w/h
      clip_from = Rubygame::Rect.new(0, 0, h, h)
      clip_to = Rubygame::Rect.new(0, 0, h, h)
      num_frames.times do
        surface = Rubygame::Surface.new(clip_to.size)
        tileset.blit surface, clip_to, clip_from
        action_imgs << surface
        clip_from.x += h
      end
    end

    action_imgs
  end

  def load_frame_set(actor, action)
    # use pngs only for now
    actor_dir = Inflector.underscore(actor.class)
    frames = Dir.glob("#{GFX_PATH}#{actor_dir}/#{action}/*.png")
    action_imgs = []

    frames = frames.sort_by {|f| File.basename(f).to_i }

    for frame in frames
      rel_path = frame.slice(GFX_PATH.size,frame.size)
      action_imgs << load_image(rel_path)
    end
    action_imgs
  end

  def load_image(file_name)
    cached_img = @loaded_images[file_name]
    if cached_img.nil?
      begin
        #cached_img = Rubygame::Surface.load(File.expand_path(GFX_PATH + file_name))
        cached_img = Rubygame::Surface.load(GFX_PATH + file_name)
      rescue Exception => ex
        #check global gamebox location
        #cached_img = Rubygame::Surface.load(File.expand_path(GAMEBOX_GFX_PATH + file_name))
        cached_img = Rubygame::Surface.load(GAMEBOX_GFX_PATH + file_name)
      end
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
      #full_name = File.expand_path(FONTS_PATH + name)
      full_name = FONTS_PATH + name
      begin
        font = TTF.new(full_name, size)
        @loaded_fonts[name][size] = font
      rescue Exception => ex
        #full_name = File.expand_path(GAMEBOX_FONTS_PATH + name)
        full_name = GAMEBOX_FONTS_PATH + name
        font = TTF.new(full_name, size)
        @loaded_fonts[name][size] = font
      end
      return font
    rescue Exception => ex
      puts "Cannot load font #{full_name}:#{ex}"
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

  def load_svg(file_name)
    # TODO create LEVEL_PATH in environment
    cached_svg = @loaded_svgs[file_name]
    if cached_svg.nil?
      #cached_svg = SvgDocument.new(File.open(File.expand_path(DATA_PATH + "levels/" + file_name + ".svg")))
      cached_svg = SvgDocument.new(File.open(DATA_PATH + "levels/" + file_name + ".svg"))
      @loaded_svgs[file_name] = cached_svg
    end
    cached_svg
  end

end
