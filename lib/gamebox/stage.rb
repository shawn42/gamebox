require 'inflector'
require 'publisher'
require 'director'
require 'viewport'
require 'backstage'
require 'arbiter'

# Stage is a state that the game is in.  (ie intro stage, multiplayer stage,
# single player stage).
class Stage
  include Arbiter
  extend Publisher
  can_fire_anything

  attr_accessor :drawables, :resource_manager, :sound_manager,
    :director, :opts, :viewport, :input_manager, :backstage

  def initialize(input_manager, actor_factory, resource_manager, sound_manager, config_manager, backstage, opts)
    @input_manager = input_manager

    @resource_manager = resource_manager
    @sound_manager = sound_manager

    @config_manager = config_manager
    res = @config_manager[:screen_resolution]
    @viewport = Viewport.new res[0], res[1]

    @actor_factory = actor_factory
    @director = create_director
    @actor_factory.director = @director
    @backstage = backstage

    @opts = opts

    setup
  end

  def create_director
    Director.new
  end

  def setup
    clear_drawables
  end

  def create_actor(type, args={})
    @actor_factory.build type, self, args
  end
  alias :spawn :create_actor 

  # extract all the params from a node that are needed to construct an actor
  def create_actors_from_svg svg_doc
    float_keys = ["x","y"]
    dynamic_actors ||= {}
    layer = svg_doc.find_group_by_label("actors")

    unless layer.nil?
      # each image in the layer is an actor
      layer.images.each do |actor_def|
        klass = actor_def.game_class.to_sym
        handle = actor_def.game_handle
        new_opts = {}
        actor_def.node.attributes.each do |k,v|
          v = v.to_f if float_keys.include? k
          new_opts[k.to_sym] = v
        end

        actor = create_actor klass, new_opts
        dynamic_actors[handle.to_sym] = actor if handle
      end
    end
    alias :spawn_from_svg :create_actors_from_svg

    dynamic_actors
  end

  def update(time)
    @director.update time
    @viewport.update time
    find_collisions unless @collidable_actors.nil?
  end

  def curtain_raising(*args)
    curtain_up *args
  end

  def curtain_dropping(*args)
    curtain_down *args
  end

  def curtain_up(*args)
  end

  def curtain_down(*args)
  end

  def draw(target)
    @drawables.keys.sort.reverse.each do |parallax_layer|

      drawables_on_parallax_layer = @drawables[parallax_layer]

      unless drawables_on_parallax_layer.nil?
        drawables_on_parallax_layer.keys.sort.each do |layer|

          trans_x = @viewport.x_offset parallax_layer
          trans_y = @viewport.y_offset parallax_layer

          drawables_on_parallax_layer[layer].each do |drawable|
            drawable.draw target, trans_x, trans_y 
          end
        end
      end
    end
  end

  def unregister_drawable(drawable)
    @drawables[drawable.parallax][drawable.layer].delete drawable
  end

  def clear_drawables
    @drawables = {}
  end

  def register_drawable(drawable)
    layer = drawable.layer
    parallax = drawable.parallax
    @drawables[parallax] ||= {}
    @drawables[parallax][layer] ||= []
    @drawables[parallax][layer] << drawable
  end

  # move all actors from one layer to another
  # note, this will remove all actors in that layer!
  def move_layer(from_parallax, from_layer, to_parallax, to_layer)
    drawable_list = @drawables[from_parallax].delete from_layer

    if drawable_list
      prev_drawable_list = @drawables[to_parallax].delete to_layer
      @drawables[to_parallax][to_layer] = drawable_list
      drawable_list.each do |drawable|
        drawable.parallax = to_parallax
        drawable.layer = to_layer
      end
    end
    prev_drawable_list

  end
end

