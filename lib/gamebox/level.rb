# Levels represent on level of game play.  Some games will likely have only one
# level. Level is responsible for loading its background, props, and directors.
require 'inflector'
require 'publisher'
require 'director'
class Level
  extend Publisher

  can_fire_anything
  attr_accessor :director, :resource_manager, :sound_manager,
    :opts, :viewport, :input_manager
    
  def initialize(actor_factory, resource_manager, sound_manager, input_manager, viewport, opts={}) 
    @director = Director.new
    @actor_factory = actor_factory
    @actor_factory.director = @director

    @sound_manager = sound_manager
    @input_manager = input_manager
    @resource_manager = resource_manager
    @viewport = viewport
    @opts = opts
    setup
  end

  def setup
  end

  def create_actor(type, args={})
    @actor_factory.build type, self, args
  end

  def update(time)
    @director.update time
  end

  def draw(target,x_off,y_off)
  end
  
  # extract all the params from a node that are needed to construct an actor
  def create_actors_from_svg
    float_keys = ["x","y"]
    dynamic_actors ||= {}
    layer = @svg_doc.find_group_by_label("actors")

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

  dynamic_actors
  end

end
