# Stage represent on level of game play.  Some games will likely have only one
# stage. Stage is responsible for loading its background, props, and directors.
# PhysicalStage adds a physics space to the Stage
require 'stage'
require 'physics'
require 'physical_director'
class PhysicalStage < Stage
  
  attr_accessor :space

  def setup
    super
    setup_space
  end
  
  def setup_space
    @space = Space.new
    @space.iterations = 20
    @space.elastic_iterations = 5
  end

  def create_director
    PhysicalDirector.new
  end

  PHYSICS_STEP = 25.0
  def update_physics(time)
    unless @physics_paused
      steps = (time/PHYSICS_STEP).ceil
      # from chipmunk demo
      dt = 1.0/60/steps
      steps.times do
        @space.step dt
      end
    end
  end
  
  def pause_physics
    @physics_paused = true
  end
  
  def restart_physics
    @physics_paused = false
  end

  def update(time)
    update_physics time 
    super
  end

  def register_physical_object(obj,static=false)
    if static
      obj.shapes.each do |shape|
        @space.add_static_shape shape
      end
    else
      @space.add_body(obj.body)
      
      obj.shapes.each do |shape|
        @space.add_shape shape
      end
    end
  end

  def register_physical_constraint(constraint)
    @space.add_constraint constraint
  end

  def unregister_physical_constraint(constraint)
    @space.remove_constraint constraint
  end

  def unregister_physical_object(obj,static=false)
    if static
      obj.physical.shapes.each do |shape|
        @space.remove_static_shape shape
      end
    else
      @space.remove_body(obj.body)
      
      obj.physical.shapes.each do |shape|
        @space.remove_shape shape
      end
    end
  end

  # Find any / all objects who's bounding box currently contains
  # the passed in screen position. Requires a block as this sets
  # a callback all the way down in Chipmunk and could be called
  # later in the future.
  #
  # This block is called on each actor found
  def pick(x, y, &block)
    @space.shape_point_query(vec2(x, y)) do |found|
      actor = @director.find_physical_obj(found)
      block.call(actor)
    end
  end

  def pause
    pause_physics
    super
  end

  def unpause
    super
    restart_physics
  end

end
