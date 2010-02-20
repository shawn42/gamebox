# this module gets mixed into a stage to allow it to handle collision detection
module Arbiter

  def register_collidable(actor)
    @collidable_actors ||= []
    unless @collidable_actors.include? actor
      actor.when :remove_me do 
        unregister_collidable actor
      end
      @collidable_actors << actor 
    end
  end

  def unregister_collidable(actor)
    @collidable_actors ||= []
    @collidable_actors.delete actor
  end

  def on_collision_of(first_objs, second_objs, &block)
    first_objs = [first_objs].flatten
    second_objs = [second_objs].flatten

    @collision_handlers ||= {}

    first_objs.each do |fobj|
      second_objs.each do |sobj|
#        puts "registering #{fobj} and #{sobj}"
        @collision_handlers[fobj] ||= {}
        @collision_handlers[fobj][sobj] = block
      end
    end
  end

  def find_collisions
    @collidable_actors ||= []
    collisions = []
    @collidable_actors.size.times do |i|
      first = @collidable_actors[i]
      (@collidable_actors.size).times do |j|
        second = @collidable_actors[i-j]

        if collide?(first, second)
          collisions << [first,second]
        end
      end
    end

    collisions.each do |collision|
      first = collision.first
      second = collision.last
      colliders = @collision_handlers[first.actor_type]
      callback = colliders[second.actor_type] unless colliders.nil?
      callback.call first, second unless callback.nil?
    end
  end

  def collide?(object, other)
    self.send "collide_#{object.shape}_#{object.shape}?", object, other
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
