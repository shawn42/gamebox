# this module gets mixed into a stage to allow it to handle collision detection
module AABBArbiter
  attr_reader :checks, :collisions

  def register_collidable(actor)
    stagehand(:spatial_tree).add(actor)
  end

  def unregister_collidable(actor)
    stagehand(:spatial_tree).remove(actor)
  end

  def interested_in_collision_of?(type1, type2)
    @collision_handlers ||= {}
    (@collision_handlers[type1] && @collision_handlers[type1][type2]) ||
    (@collision_handlers[type2] && @collision_handlers[type2][type1])
  end

  def find_collisions
    aabb_tree = stagehand(:spatial_tree)
    collidable_actors = aabb_tree.moved_items.values

    collisions = {}

    collidable_actors.each do |first|
      if first.is? :collidable
        # HUH? it appears that querying modifies the tree somehow?
        # aabb_tree.query(first.bb) do |second|
        aabb_tree.potential_collisions(first) do |second|

          if second.is? :collidable
            if first != second &&
              interested_in_collision_of?(first.actor_type, second.actor_type) &&
              collide?(first, second)
              if !collisions[second] || (collisions[second] && !collisions[second].include?(first))
                collisions[first] ||= []
                collisions[first] << second
              end
            end
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
    aabb_tree.reset
  end

end
