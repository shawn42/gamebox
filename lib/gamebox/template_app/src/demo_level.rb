require 'physical_level'
require 'physical_director'
require 'ship_director'

class DemoLevel < PhysicalLevel
  def setup
    @score = 0
    ship = @actor_factory.build :ship, self
    ship.warp vec2(300,300)

    @ship_dir = ShipDirector.new

    @ship_dir.when :create_bullet do |ship|
      bullet = @actor_factory.build :bullet, self
      bullet.warp vec2(ship.x,ship.y)
      # TODO how to get the bullet pointed where it should go?
#      bullet.body.rot = ship.body.rot
      bullet.dir = vec2(ship.body.rot.x,ship.body.rot.y)
      @ship_dir.add_actor bullet
    end

    @ship_dir.add_actor ship
    @rock_dir = PhysicalDirector.new

    @directors << @rock_dir
    @directors << @ship_dir

    10.times do
      rock = @actor_factory.build :rock, self
      x,y = rand(400)+200,rand(300)+200
      rock.warp vec2(x,y)
      @rock_dir.add_actor rock
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
#      fire :ship_death
#      @rock_dir.remove_physical_obj rock
#      @ship_dir.remove_physical_obj ship
      puts "SHIP ASPLODE!!"
#      exit
    end
    @space.add_collision_func(:rock, :bullet) do |rock, bullet|
      @score += 10
      @ship_dir.remove_physical_obj bullet
      @rock_dir.remove_physical_obj rock
      p "SCORE: #{@score}"
    end

    @stars = []
    20.times do 
      @stars << vec2(rand(@width),rand(@height))
    end
  end

  def draw(target)
    target.fill [25,25,25,255]
    for star in @stars
      target.draw_circle_s([star.x,star.y],1,[255,255,255,255])
    end
  end
end

