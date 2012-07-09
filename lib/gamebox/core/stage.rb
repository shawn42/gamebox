# Stage is a state that the game is in.  (ie intro stage, multiplayer stage,
# single player stage).
class Stage
  include Arbiter
  extend Publisher
  can_fire_anything

  construct_with :input_manager, :actor_factory, :resource_manager, 
    :sound_manager, :config_manager, :director, :timer_manager, 
    :this_object_context

  def self.inherited(kid)
    kid.construct_with *self.object_definition.component_names
  end

  attr_accessor :opts, :viewport, :backstage

  def configure(backstage, opts)
    res = config_manager[:screen_resolution]
    @viewport = Viewport.new res[0], res[1]
    this_object_context[:viewport] = @viewport

    @stagehands = {}
    @backstage = backstage
    @opts = opts

    setup
  end

  def setup
    clear_drawables
  end

  def create_actor(type, args={})
    actor_factory.build type, args
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
    director.update time
    @viewport.update time
    @stagehands.each do |name, stagehand|
      stagehand.update time 
    end
    find_collisions
    timer_manager.update time
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
    following = @viewport.follow_target

    center_x = nil
    center_y = nil
    if following.nil?
      view_bounds = @viewport.bounds
      center_x = view_bounds.centerx
      center_y = view_bounds.centery
    else
      center_x = following.x
      center_y = following.y
    end
    target.rotate(@viewport.rotation, center_x, center_y) do
      z = 0
      @parallax_layers.each do |parallax_layer|
        drawables_on_parallax_layer = @drawables[parallax_layer]

        if drawables_on_parallax_layer
          @layer_orders[parallax_layer].each do |layer|

            trans_x = @viewport.x_offset parallax_layer
            trans_y = @viewport.y_offset parallax_layer

            z += 1
            drawables_on_parallax_layer[layer].each do |drawable|
              drawable.draw target, trans_x, trans_y, z
            end
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
    @layer_orders = {}
    @parallax_layers = []
  end

  def register_drawable(drawable)
    layer = drawable.layer
    parallax = drawable.parallax
    unless @drawables[parallax]
      @drawables[parallax] = {}
      @parallax_layers = @drawables.keys.sort.reverse
    end
    unless @drawables[parallax][layer]
      @drawables[parallax][layer] = []
      @layer_orders[parallax] = @drawables[parallax].keys.sort
    end
    @drawables[parallax][layer] << drawable
  end

  # move all actors from one layer to another
  # note, this will remove all actors in that layer!
  def move_layer(from_parallax, from_layer, to_parallax, to_layer)
    drawable_list = @drawables[from_parallax][from_layer].dup

    drawable_list.each do |drawable|
      unregister_drawable drawable      
      drawable.parallax = to_parallax
      drawable.layer = to_layer
      register_drawable drawable      
    end
  end

  def on_pause(&block)
    @pause_listeners ||= []
    @pause_listeners << block if block_given?
  end

  def on_unpause(&block)
    @unpause_listeners ||= []
    @unpause_listeners << block if block_given?
  end

  def paused?
    @pause
  end

  def pause
    @pause_listeners ||= []
    @paused = true
    director.pause
    timer_manager.pause
    input_manager.pause
    @pause_listeners.each do |listener|
      listener.call
    end
  end

  def unpause
    @unpause_listeners ||= []
    director.unpause
    input_manager.unpause
    timer_manager.unpause
    @unpause_listeners.each do |listener|
      listener.call
    end
    @paused = true
  end

  def stagehand(stagehand_sym, opts={})
    @stagehands[stagehand_sym] ||= create_stagehand(stagehand_sym, opts)
  end

  # pauses the current stage, creates an actor using args, unpauses on actor death
  #
  # Example:
  #  modal_actor :dialog, x: 40, y: 50, message: "WOW"
  def modal_actor(*args)
    on_pause do
      pause_actor = create_actor *args
      pause_actor.when :remove_me do
        @pause_listeners = nil
        unpause
        yield if block_given?
      end
    end
    pause

  end

  private
  def create_stagehand(name, opts)
    underscored_class = "#{name}_stagehand"
    klass = ClassFinder.find underscored_class
    klass.new self, opts
  end


end

