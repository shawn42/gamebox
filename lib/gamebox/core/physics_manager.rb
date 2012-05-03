# PhysicsManager creates and manages chipmunks space.
class PhysicsManager
  extend Forwardable
  def_delegators :@space, :elastic_iterations=, :damping=, :gravity=

  attr_accessor :space
  def configure
    @space = CP::Space.new
    @space.iterations = 20
    @space.elastic_iterations = 5
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
  end

  # allows for passing arrays of collision types not just single ones
  # add_collision_func([:foo,:bar], [:baz,:yar]) becomes:
  # add_collision_func(:foo, :baz)
  # add_collision_func(:foo, :yar)
  # add_collision_func(:bar, :baz)
  # add_collision_func(:bar, :yar)
  def add_collision_func(first_objs, second_objs, &block)
    firsts = [first_objs].flatten
    seconds = [second_objs].flatten
    
    firsts.each do |f|
      seconds.each do |s|
        @space.add_collision_func(f,s) do |a, b|
          block.call a.actor, b.actor
        end
      end
    end
  end

  def register_physical_object(obj,static=false)
    obj.when :remove_me do
      unregister_physical_object obj
    end

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
      obj.shapes.each do |shape|
        @space.remove_static_shape shape
      end
    else
      @space.remove_body(obj.body)
      
      obj.shapes.each do |shape|
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
  # def pick(x, y, &block)
  #   @space.shape_point_query(vec2(x, y)) do |found|
  #     actor = @director.find_physical_obj(found)
  #     block.call(actor)
  #   end
  # end

  def pause
    pause_physics
  end

  def unpause
    restart_physics
  end
end
