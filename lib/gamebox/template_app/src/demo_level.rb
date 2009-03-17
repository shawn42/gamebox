require 'physical_level'
require 'ship_director'

class DemoLevel < PhysicalLevel
  def setup
    @score = 0
    ship = @actor_factory.build :ship, self
    ship.warp vec2(300,300)

    ship_dir = ShipDirector.new

    ship_dir.when :create_bullet do |ship|
      bullet = @actor_factory.build :bullet, self
      bullet.when :kill_me do
        ship_dir.kill_actor bullet
      end
      bullet.warp vec2(ship.x,ship.y)
      bullet.dir = vec2(ship.body.rot.x,ship.body.rot.y)
      ship_dir.add_actor bullet
    end

    @directors << ship_dir
    ship_dir.add_actor ship

    rock_dir = Director.new
    @directors << rock_dir

    10.times do
      rock = @actor_factory.build :rock, self
      x,y = rand(400)+200,rand(300)+200
      rock.warp vec2(x,y)
      rock_dir.add_actor rock
    end

    left_wall = @actor_factory.build :left_wall, self,
      :view => WallView
    top_wall = @actor_factory.build :top_wall, self,
      :view => WallView
    right_wall = @actor_factory.build :right_wall, self,
      :view => WallView
    bottom_wall = @actor_factory.build :bottom_wall, self,
      :view => WallView

    right_wall.warp vec2(1023,0)
    bottom_wall.warp vec2(0,799)

    # TODO get this from screen config
    @width = 1024
    @height = 800
    # setup ship torusness
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

    # setup rock torusness
    @space.add_collision_func(:rock, :left_wall) do |rock, wall|
      bb = rock.bb
      rock.body.p = vec2(@width-bb.r-bb.l,rock.body.p.y)
    end
    @space.add_collision_func(:rock, :right_wall) do |rock, wall|
      bb = rock.bb
      rock.body.p = vec2(bb.r-bb.l,rock.body.p.y)
    end
    @space.add_collision_func(:rock, :top_wall) do |rock, wall|
      bb = rock.bb
      rock.body.p = vec2(rock.body.p.x,@height-bb.b-bb.t)
    end
    @space.add_collision_func(:rock, :bottom_wall) do |rock, wall|
      bb = rock.bb
      rock.body.p = vec2(rock.body.p.x,bb.t-bb.b)
    end

    # ship rock collision
    @space.add_collision_func(:rock, :ship) do |rock, ship|
      p "SHIP ASPLODE!!"
    end
    @space.add_collision_func(:rock, :bullet) do |rock, bullet|
      @score += 10
      p "SCORE: #{@score}"
    end

  end

  def draw(target)
    target.fill [255,255,255,255]
  end
end

