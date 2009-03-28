require 'physical_level'
require 'physical_director'
require 'ship_director'

class DemoLevel < PhysicalLevel
  def setup
    @ship = @actor_factory.build :ship, self
    @ship.warp vec2(300,300)

    @ship_dir = ShipDirector.new
    @rock_dir = PhysicalDirector.new
    @score_dir = Director.new

    @ship_dir.when :create_bullet do |ship|
      bullet = @actor_factory.build :bullet, self
      bullet.warp vec2(ship.x,ship.y)
      bullet.body.a += ship.body.a
      bullet.dir = vec2(ship.body.rot.x,ship.body.rot.y)
      @ship_dir.add_actor bullet
    end

    @ship_dir.add_actor @ship

    @directors << @rock_dir
    @directors << @ship_dir
    @directors << @score_dir

    @score = @actor_factory.build :score, self
    @score.x = 10
    @score.y = 10
    @score_dir.add_actor @score

    @opts[:rocks].times do
      rock = @actor_factory.build :rock, self
      x,y = rand(400)+200,rand(300)+200
      rock.warp vec2(x,y)
      @rock_dir.add_actor rock
    end

    left_wall = @actor_factory.build :left_wall, self
    top_wall = @actor_factory.build :top_wall, self
    right_wall = @actor_factory.build :right_wall, self
    bottom_wall = @actor_factory.build :bottom_wall, self

    right_wall.warp vec2(1023,0)
    bottom_wall.warp vec2(0,799)

    # TODO get this from screen config
    @width = 1024
    @height = 800
    # setup ship torusness
    @space.add_collision_func(:ship, :left_wall) do |ship, wall|
      ship.body.p = vec2(@width-ship.bb.r-ship.bb.l,ship.body.p.y)
    end
    @space.add_collision_func(:ship, :right_wall) do |ship, wall|
      ship.body.p = vec2(ship.bb.r-ship.bb.l,ship.body.p.y)
    end
    @space.add_collision_func(:ship, :top_wall) do |ship, wall|
      ship.body.p = vec2(ship.body.p.x,@height-ship.bb.b-ship.bb.t)
    end
    @space.add_collision_func(:ship, :bottom_wall) do |ship, wall|
      ship.body.p = vec2(ship.body.p.x,ship.bb.t-ship.bb.b)
    end

    # setup rock torusness
    @space.add_collision_func(:rock, :left_wall) do |rock, wall|
      rock.body.p = vec2(@width-rock.bb.r-rock.bb.l,rock.body.p.y)
    end
    @space.add_collision_func(:rock, :right_wall) do |rock, wall|
      rock.body.p = vec2(rock.bb.r-rock.bb.l,rock.body.p.y)
    end
    @space.add_collision_func(:rock, :top_wall) do |rock, wall|
      rock.body.p = vec2(rock.body.p.x,@height-rock.bb.b-rock.bb.t)
    end
    @space.add_collision_func(:rock, :bottom_wall) do |rock, wall|
      rock.body.p = vec2(rock.body.p.x,rock.bb.t-rock.bb.b)
    end

    # ship rock collision
    @space.add_collision_func(:rock, :ship) do |rock, ship|
      @ship_dir.find_physical_obj(ship).when :remove_me do
        fire :prev_level
      end
      @ship_dir.remove_physical_obj ship
    end

    @space.add_collision_func(:rock, :bullet) do |rock, bullet|
      @score += 10
      @ship_dir.remove_physical_obj bullet
      @rock_dir.remove_physical_obj rock
    end

    @stars = []
    20.times { @stars << vec2(rand(@width),rand(@height)) }
  end

  def update(time)
    update_physics time
    for dir in @directors
      dir.update time
    end
    if @rock_dir.empty?
      @ship.when :remove_me do
        fire :next_level
      end
      @ship.remove_self
    end
  end

  def draw(target)
    target.fill [25,25,25,255]
    for star in @stars
      target.draw_circle_s([star.x,star.y],1,[255,255,255,255])
    end
  end
end

