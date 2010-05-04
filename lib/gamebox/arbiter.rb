# this module gets mixed into a stage to allow it to handle collision detection
module Arbiter
  attr_reader :checks, :collisions

  def register_collidable(actor)
    @spatial_hash = stagehand(:spatial)
    @collidable_actors ||= []
    unless @collidable_actors.include? actor
      actor.when :remove_me do 
        unregister_collidable actor
      end
      @collidable_actors << actor 
      @spatial_hash.add(actor)
    end
  end

  def unregister_collidable(actor)
    @collidable_actors ||= []
    @collidable_actors.delete actor
    @spatial_hash.remove(actor)
  end

  def on_collision_of(first_objs, second_objs, &block)
    first_objs = [first_objs].flatten
    second_objs = [second_objs].flatten

    @collision_handlers ||= {}

    first_objs.each do |fobj|
      second_objs.each do |sobj|
        if fobj.to_i < sobj.to_i
          @collision_handlers[fobj] ||= {}
          @collision_handlers[fobj][sobj] = block
        else
          @collision_handlers[sobj] ||= {}
          @collision_handlers[sobj][fobj] = block
        end
      end
    end
  end

  def run_callbacks(collisions)
    @collision_handlers ||= {}
    collisions.each do |collision|
      first = collision.first
      second = collision.last
      unless first.actor_type.to_i < second.actor_type.to_i
        tmp = first
        first = second
        second = tmp
        swapped = true
      end

      colliders = @collision_handlers[first.actor_type]
      callback = colliders[second.actor_type] unless colliders.nil?
      unless callback.nil?
        if swapped
          callback.call second, first 
        else
          callback.call first, second 
        end
      end
    end
  end

  def find_collisions
    @collidable_actors ||= []
    @checks = 0
    @collisions = 0
    tmp_collidable_actors = @collidable_actors.dup
    collisions = {}

    @collidable_actors.each do |first|
      x = first.x - @spatial_hash.cell_size
      y = first.y - @spatial_hash.cell_size
      w = @spatial_hash.cell_size * 3
      h = w

      tmp_collidable_actors = @spatial_hash.neighbors_of(first)

      tmp_collidable_actors.each do |second|
        @checks += 1
        if first != second && collide?(first, second)
          collisions[second] ||= []
          if !collisions[second].include?(first)
            @collisions += 1
            collisions[first] ||= []
            collisions[first] << second
          end
        end
      end
    end
    unique_collisions = []
    collisions.each do |first,seconds|
      seconds.each do |second|
        unique_collisions << [first,second]
      end
    end
    run_callbacks unique_collisions
  end

  def collide?(object, other)
    self.send "collide_#{object.collidable_shape}_#{other.collidable_shape}?", object, other
  end

  def collide_circle_circle?(object, other)
#    puts "comparing #{object.actor_type}[#{object.object_id}] to #{other.actor_type}[#{other.object_id}]"
    x = object.x + object.radius
    y = object.y + object.radius
    x_prime = other.x + other.radius
    y_prime = other.y + other.radius

    x_dist  = (x_prime - x) * (x_prime - x)
    y_dist  = (y_prime - y) * (y_prime - y)

    total_radius = object.radius + other.radius
    x_dist + y_dist < (total_radius) * (total_radius)
  end

end
