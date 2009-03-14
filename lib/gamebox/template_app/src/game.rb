require 'mode'
require 'physical_level'
require 'director'
require 'actor'
require 'actor_view'
require 'actor_factory'


class ShipView < ActorView
  def setup
    # TODO subscribe for all events here
  end
  def draw(target)
    x = @actor.x
    y = @actor.y
    bb = @actor.shape.bb
    target.draw_box_s [bb.l,bb.t], [bb.r,bb.b], [50,250,150,255] 
  end
end

class LeftWall < Actor
  has_behaviors :physical => {:shape => :poly, 
    :fixed => true,
    :mass => 100,
    :verts => [[0,0],[0,800],[1,800],[1,0]]}
end

class TopWall < Actor
  has_behaviors :physical => {:shape => :poly, 
    :fixed => true,
    :mass => 100,
    :verts => [[0,0],[0,1],[1024,1],[1024,0]]}
end

class BottomWall < Actor
  has_behaviors :physical => {:shape => :poly, 
    :fixed => true,
    :mass => 100,
    :verts => [[0,0],[0,1],[1024,1],[1024,0]]}
end

class RightWall < Actor
  has_behaviors :physical => {:shape => :poly, 
    :fixed => true,
    :mass => 100,
    :verts => [[0,0],[0,800],[1,800],[1,0]]}
end

class WallView < ActorView
  def draw(target)
    x = @actor.x
    y = @actor.y

    bb = @actor.shape.bb
    target.draw_box_s [bb.l,bb.t], [bb.r,bb.b], [250,150,150,255] 
  end
end

class Ship < Actor
  has_behaviors :physical => {:shape => :circle, 
    :mass => 40,
    :radius => 10}
  attr_accessor :moving_forward, :moving_back,
    :moving_left, :moving_right
  def setup
    @speed = 0.7
    @turn_speed = 0.003

    i = @input_manager
    i.reg KeyDownEvent, K_SPACE do
      warp vec2(rand(400)-100,rand(400)-100)
    end
    i.reg KeyDownEvent, K_LEFT do
      @moving_left = true
    end
    i.reg KeyDownEvent, K_RIGHT do
      @moving_right = true
    end
    i.reg KeyDownEvent, K_UP do
      @moving_forward = true
    end
    i.reg KeyDownEvent, K_DOWN do
      @moving_back = true
    end
    i.reg KeyUpEvent, K_LEFT do
      @moving_left = false
    end
    i.reg KeyUpEvent, K_RIGHT do
      @moving_right = false
    end
    i.reg KeyUpEvent, K_UP do
      @moving_forward = false
    end
    i.reg KeyUpEvent, K_DOWN do
      @moving_back = false
    end
  end

  def moving_forward?;@moving_forward;end
  def moving_back?;@moving_back;end
  def moving_left?;@moving_left;end
  def moving_right?;@moving_right;end
  def update(time)
    move_forward time if moving_forward?
    move_back time if moving_back?
    move_left time if moving_left?
    move_right time if moving_right?
  end

  def move_right(time)
    @behaviors[:physical].body.a += time*@turn_speed
    @behaviors[:physical].body.w += time*@turn_speed/5.0 if @behaviors[:physical].body.w > 2.5
  end
  def move_left(time)
    @behaviors[:physical].body.a -= time*@turn_speed
    @behaviors[:physical].body.w -= time*@turn_speed/5.0 if @behaviors[:physical].body.w > 2.5
  end
  def move_back(time)
    @behaviors[:physical].body.apply_impulse(-@behaviors[:physical].body.rot*time*@speed, ZeroVec2) if @behaviors[:physical].body.v.length < 400
  end
  def move_forward(time)
    @behaviors[:physical].body.apply_impulse(@behaviors[:physical].body.rot*time*@speed, ZeroVec2) if @behaviors[:physical].body.v.length < 400
  end
end

class ShipDirector < Director
  def update(time)
    # TODO teleport to other side of map?
    for act in @actors
      act.update time
    end
  end
end

class AsteroidLevel < PhysicalLevel
  def setup
    # TODO get this from screen of config
    @width = 1024
    @height = 800
    @space.add_collision_func(:ship, :left_wall) do |ship, wall|
      bb = ship.bb
      ship.body.p = vec2(@width-bb.r-bb.l,ship.body.p.y)
    end
    @space.add_collision_func(:ship, :right_wall) do |ship, wall|
      bb = ship.bb
      ship.body.p = vec2(bb.r-bb.l,ship.body.p.y)
    end
    @space.add_collision_func(:ship, :top_wall) do |ship, wall|
      bb = ship.bb
      ship.body.p = vec2(ship.body.p.x,@height-bb.b-bb.t)
    end
    @space.add_collision_func(:ship, :bottom_wall) do |ship, wall|
      bb = ship.bb
      ship.body.p = vec2(ship.body.p.x,bb.t-bb.b)
    end
  end
end


class Game

  constructor :wrapped_screen, :input_manager, :sound_manager,
    :mode_manager, :actor_factory

  def setup
    @sound_manager.play :current_rider

    # tmp code here, to draw an actor
    # WHERE SHOULD THIS BUILDING LOGIC COME FROM?
    #  - file describing modes? or hard code them?
    #  - levels in each mode? or hard code them?
    #  - directorys in the level? in the "level definition"?
    mode = Mode.new
    level = AsteroidLevel.new
    mode.level = level
    @mode_manager.add_mode :demo, mode

    ship = @actor_factory.build :ship
    ship.warp vec2(300,300)

    dir = ShipDirector.new
    level.directors << dir
    dir.actors << ship

    left_wall = @actor_factory.build :left_wall, 
      :view => WallView
    top_wall = @actor_factory.build :top_wall, 
      :view => WallView
    right_wall = @actor_factory.build :right_wall, 
      :view => WallView
    bottom_wall = @actor_factory.build :bottom_wall, 
      :view => WallView

    right_wall.warp vec2(1023,0)
    bottom_wall.warp vec2(0,799)

    @mode_manager.change_mode_to :demo
  end

  def update(time)
    @mode_manager.update time
    draw
  end

  def draw
    @mode_manager.draw @wrapped_screen
    @wrapped_screen.flip
  end

end
