$: << "#{File.dirname(__FILE__)}/../config"
require "fileutils"

class ResourceManager

  construct_with :wrapped_screen

  def initialize
    @loaded_images = {}
    @loaded_fonts = {}
    @loaded_svgs = {}
    @window = wrapped_screen.screen
  end

  def load_actor_image(actor)
    # use pngs only for now
    # actor_name = Inflector.underscore(actor.class)
    return load_image("#{actor.actor_type}.png")
  end

  def load_animation_set(actor, action)
    actor_dir = Inflector.underscore(actor.class)
    using_tileset = File.exist?("#{Gamebox.configuration.gfx_path}#{actor_dir}/#{action}.png")
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
    tileset_name = "#{actor_dir}/#{action}.png"
    tileset = load_image tileset_name

    action_imgs = []
    w = tileset.width
    h = tileset.height

    if h > w
      # down
      num_frames = h/w
      action_imgs = Image.load_tiles @window, Gamebox.configuration.gfx_path+tileset_name, -1, -num_frames, true
    else
      # right
      num_frames = w/h
      action_imgs = Image.load_tiles @window, Gamebox.configuration.gfx_path+tileset_name, -num_frames, -1, true
    end

    action_imgs
  end

  def load_frame_set(actor, action)
    # use pngs only for now
    frames = Dir.glob("#{Gamebox.configuration.gfx_path}#{actor.actor_type}/#{action}/*.png")
    action_imgs = []

    frames = frames.sort_by {|f| File.basename(f).to_i }

    for frame in frames
      rel_path = frame.slice(Gamebox.configuration.gfx_path.size,frame.size)
      action_imgs << load_image(rel_path)
    end
    action_imgs
  end

  def load_image(file_name)
    cached_img = @loaded_images[file_name]
    if cached_img.nil?
      begin
        full_name = Gamebox.configuration.gfx_path + file_name
        if ! File.exist? full_name
          #check global gamebox location
          full_name = GAMEBOX_Gamebox.configuration.gfx_path + file_name
        end
        cached_img = Image.new(@window, full_name)
      rescue Exception => ex
        # log "Cannot load image #{file_name}", :warn
      end
      @loaded_images[file_name] = cached_img
    end
    cached_img
  end

  def load_music(full_name)
    begin
      music = Song.new(@window, full_name)
      return music
    rescue Exception => ex
      log "Cannot load music " + full_name + " : " + ex, :warn
    end
  end

  def load_sound(full_name)
    begin
      sound = Sample.new(@window, full_name)
      return sound
    rescue Exception => ex
      log "Cannot load sound " + full_name + " : " + ex.inspect, :warn
    end
  end

  # loads fonts from the fonts dir and caches them for later
  def load_font(name, size)
    @loaded_fonts[name] ||= {}
    return @loaded_fonts[name][size] if @loaded_fonts[name][size]
    begin
      if name =~ /^\// and File.exists?(name)
        font = Font.new(@window, name, size)
        @loaded_fonts[name][size] = font
      else
        full_name = FONTS_PATH + name
        if File.exist? full_name
          font = Font.new(@window, full_name, size)
          @loaded_fonts[name][size] = font
        else
          full_name = GAMEBOX_FONTS_PATH + name
          font = Font.new(@window, full_name, size)
          @loaded_fonts[name][size] = font
        end
      end
      return font
    rescue Exception => ex
      debug "Cannot load font #{full_name}:#{ex}"
    end
    return nil
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

  def load_tiles(filename, tile_width, tile_height)
    Image.load_tiles @window, Gamebox.configuration.gfx_path+filename, tile_width, tile_height, true
  end


end
