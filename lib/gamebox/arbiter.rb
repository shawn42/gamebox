# this module gets mixed into a stage to allow it to handle collision detection
module Arbiter
  attr_reader :checks, :collisions

  def register_collidable(actor)
    stagehand(:spatial).add(actor) if stagehand(:spatial).items[actor].nil?
  end

  def on_collision_of(first_objs, second_objs, &block)
    first_objs = [first_objs].flatten
    second_objs = [second_objs].flatten

    @collision_handlers ||= {}

    first_objs.each do |fobj|
      second_objs.each do |sobj|
        if fobj < sobj
          @collision_handlers[fobj] ||= {}
          @collision_handlers[fobj][sobj] = [false,block]
        else
          @collision_handlers[sobj] ||= {}
          @collision_handlers[sobj][fobj] = [true,block]
        end
      end
    end
  end

  def run_callbacks(collisions)
    @collision_handlers ||= {}
    collisions.each do |collision|
      first = collision.first
      second = collision.last
      unless first.actor_type < second.actor_type
        tmp = first
        first = second
        second = tmp
      end

      colliders = @collision_handlers[first.actor_type]
      swapped, callback = colliders[second.actor_type] unless colliders.nil?
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
    spatial_hash = stagehand(:spatial)
    @collidable_actors = spatial_hash.items.values
    @checks = 0
    @collisions = 0
    tmp_collidable_actors = @collidable_actors.dup
    collisions = {}

    @collidable_actors.each do |first|
      x = first.x - spatial_hash.cell_size
      y = first.y - spatial_hash.cell_size
      # TODO base this on size of object
      w = spatial_hash.cell_size * 3
      h = w

      tmp_collidable_actors = spatial_hash.neighbors_of(first)

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
    # TODO perf analysis of this
    self.send "collide_#{object.collidable_shape}_#{other.collidable_shape}?", object, other
  end

  def collide_circle_circle?(object, other)
    x = object.center_x
    y = object.center_y
    x_prime = other.center_x
    y_prime = other.center_y

    x_dist  = (x_prime - x) * (x_prime - x)
    y_dist  = (y_prime - y) * (y_prime - y)

    total_radius = object.radius + other.radius
    x_dist + y_dist <= (total_radius * total_radius)
  end

  # Idea from:
  # http://gpwiki.org/index.php/Polygon_Collision
  # and http://www.gamedev.net/community/forums/topic.asp?topic_id=540755&whichpage=1&#3488866
  def collide_polygon_polygon?(object, other)
    if collide_circle_circle? object, other
      # collect vector's perp
      potential_sep_axis = 
        (object.cw_world_edge_normals | other.cw_world_edge_normals).uniq
      potential_sep_axis.each do |axis|
        return false unless project_and_detect(axis, object, other)           
      end 
    else
      return false
    end
    true
  end
  alias collide_aabb_aabb? collide_polygon_polygon?

  # returns true if the projections overlap
  def project_and_detect(axis, a, b)
    a_min, a_max = send("#{a.collidable_shape}_interval", axis, a)
    b_min, b_max = send("#{b.collidable_shape}_interval", axis, b)

    a_min <= b_max && b_min <= a_max
  end

  def polygon_interval(axis, object)
    min = max = nil
    object.cw_world_points.each do |edge|
      # vector dot product
      d = edge[0] * axis[0] + edge[1] * axis[1]
      min ||= d
      max ||= d
      min = d if d < min
      max = d if d > max
    end
    [min,max]
  end
  alias aabb_interval polygon_interval

  def circle_interval(axis, object)
    axis_x = axis[0]
    axis_y = axis[1]

    obj_x = object.center_x
    obj_y = object.center_y

    length = Math.sqrt(axis_x * axis_x + axis_y * axis_y)
    cn = axis_x*obj_x + axis_y*obj_y
    rlength = object.radius*length
    min = cn - rlength
    max = cn + rlength
    [min,max]
  end

  def collide_polygon_circle?(object, other)
    collide_circle_polygon?(other, object)
  end
  alias collide_aabb_circle?  collide_polygon_circle?

  def collide_circle_polygon?(object, other)
    if collide_circle_circle? object, other
      potential_sep_axis = other.cw_world_edge_normals
      potential_sep_axis.each do |axis|
        return false unless project_and_detect(axis, object, other)           
      end 
      true 
    else
      false
    end
  end
  alias collide_circle_aabb? collide_circle_polygon?
end
