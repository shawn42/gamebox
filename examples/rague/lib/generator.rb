# take from ruby quiz solutions
# Benjohn Barnes


# This class basically implements a random walk. I remember
# my direction, and it's this that I randomly adjust, rather
# than simply jittering my position.
class Walker
  attr_accessor :x, :y, :direction
  
  def initialize(x=0, y=0, direction=0)
    @x, @y, @direction = x, y, direction
  end

  # Handy for testing.
  def position
    [x,y]
  end
  
  # Adjust direction, and walk once.
  def wander
    perturb_direction
    walk
  end

  # Make the child pointing of 90 degrees away from me.
  def create_child
    Walker.new(x, y, direction + 2*rand(2) - 1)
  end

  def perturb_direction
    @direction += rand*wiggle_max - (wiggle_max/2)
  end
  
  def walk(d = direction_with_smoothing_fuzz)
    # Ensure that the direction is correctly wrapped around.
    d = (d.round)%4
    @x += [1,0,-1,0][d]
    @y += [0,1,0,-1][d]
    self
  end
  
  # Adding some noise on to the direction "stocastically" samples
  # it, smoothing off turns, and making it more catacombey.
  def direction_with_smoothing_fuzz
    @direction + rand*smoothing - smoothing/2
  end

  # How wiggley are the dungeons? Bigger numbers are more wiggly
  # and compact.
  def wiggle_max
    0.5
  end
  
  # How smooth are tunnels? Larger numbers give smoother more
  # 'catacombe' like tunnels (and smaller dungeons). Smaller
  # numbers give more cartesian & straight tunnels.
  def smoothing
    0.9
  end

end


class Arena
  attr_reader :left, :right, :top, :bottom
  def initialize
    @arena = Hash.new {|h,k| h[k]=Hash.new('#')}
    @left = @right = @top = @bottom = 0
  end
  
  def [](x,y)
    @arena[y][x]
  end

  def []=(x,y,v)
    # I originally worked out the width and height at the end by scanning the map.
    # I was also using a single map, rather than the 'map in a map' now used. I
    # found that dungeon creation  was slow, but almost all of it was the final
    # rendering stage, so switched over to the current approach.
    @arena[y][x]=v
    @left = [@left, x].min
    @right = [@right, x].max
    @top = [@top, y].min
    @bottom = [@bottom, y].max
  end

  def to_s
    to_array.collect {|row| row.join}.join("\n")
  end

  def to_array
    (top-1..bottom+1).collect do |y|
      (left-1..right+1).collect do |x|
        self[x,y]
      end
    end
  end
end

class Generator
  attr_accessor :start_x, :start_y
  def create_dungeon( arena, walk_length, have_stairs = true, walker = Walker.new )
    while(walk_length>0)
      walk_length -=1
    
      # Cut out a bit of tunnel where I am.
      arena[*walker.position] = ' '
      walker.wander

      # Bosh down a room ocaissionally.
      if(walk_length%80==0)
        create_room(arena, walker)
      end

      # Spawn off a child now and then. Split the remaining walk_length with it.
      # Only one of us gets the stairs though.
      if(walk_length%40==0)
        child_walk_length = rand(walk_length)
        walk_length -= child_walk_length
        if child_walk_length > walk_length
          create_dungeon(arena, child_walk_length, have_stairs, walker.create_child)
          have_stairs = false
        else
          create_dungeon(arena, child_walk_length, false, walker.create_child)
        end
      end
    end

    # Put in the down stairs, if I have them.
    if(have_stairs)
      arena[*(walker.position)] = '>'
    end
    arena
  end

  def create_room(arena, walker)
    max = 10
    width = -rand(max)..rand(max)
    height = -rand(max)..rand(max)
    height.each do |y|
      width.each do |x|
        arena[x+walker.x, y+walker.y] = ' '
      end
    end
  end
end




