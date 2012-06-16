# PhysicsManager creates and manages chipmunks space.
class PhysicsManager
  extend Forwardable
  def_delegators( :@space,
                  :damping,            :damping=,
                  :gravity,            :gravity=,
                  :iterations,         :iterations= )

  attr_accessor :space

  # Time per physics step, in milliseconds (default 15). Small steps
  # make the simulation more stable than large steps, but if the step
  # is too small, it may negatively affect performance, i.e. cause
  # very high CPU use and/or low framerate.
  attr_reader :step_size
  def step_size=(new_step_size)
    @step_size = new_step_size.to_f
    @step_size_seconds = @step_size / 1000
  end


  def configure
    @space = CP::Space.new
    @space.iterations = 10
    self.step_size = 15
    @leftover_step_time = 0
  end


  def update(time)
    update_physics time 
  end

  def update_physics(time)
    unless @physics_paused
      @leftover_step_time += time
      steps = (@leftover_step_time / @step_size).ceil
      steps.times do
        @space.step @step_size_seconds
      end
      @leftover_step_time -= (steps * @step_size).round
    end
  end
  

  def pause
    pause_physics
  end

  def unpause
    restart_physics
  end

  def pause_physics
    @physics_paused = true
  end
  
  def restart_physics
    @physics_paused = false
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
end
