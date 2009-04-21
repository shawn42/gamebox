require 'physical_level'
require 'walls'

class DemoLevel < PhysicalLevel
  attr_accessor :score
  def setup
    @sound_manager.play :roids

    @ship = create_actor :ship, :x => 300, :y => 300
#    @ship.warp vec2(300,300)

    @score = create_actor :score
    @score.x = 10
    @score.y = 10

    prev_level = @opts[:prev_level]
    @score += prev_level.score.score if prev_level

    @rocks = []
    @opts[:rocks].times do
      rock = create_actor :rock
      @rocks << rock
      x,y = rand(400)+200,rand(300)+200
      rock.warp vec2(x,y)
    end

    left_wall = create_actor :left_wall, :view => false
    top_wall = create_actor :top_wall, :view => false
    right_wall = create_actor :right_wall, :view => false
    bottom_wall = create_actor :bottom_wall, :view => false

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
      shippy = @director.find_physical_obj ship
      unless shippy.invincible?
        @sound_manager.play_sound :implosion
        shippy.when :remove_me do
          fire :prev_level
        end
        shippy.remove_self if shippy.alive?
      end
    end

    @space.add_collision_func(:rock, :bullet) do |rock, bullet|
      @sound_manager.play_sound :implosion

      rocky = @director.find_physical_obj rock
      rocky.when :remove_me do
        @score += 10
      end

      if rocky.alive?
        rocky.remove_self 
        x,y = rocky.x, rocky.y
        (3+rand(3)).times do
          bit = create_actor :rock_bit
          bit.warp vec2(x,y)
        end
      end

      @rocks.delete rocky

      @director.remove_physical_obj bullet
    end

    @stars = []
    20.times { @stars << vec2(rand(@width),rand(@height)) }
  end

  def update(time)
    update_physics time
    @director.update time

    if @rocks.empty?
      @ship.when :remove_me do
        fire :next_level
      end
      @ship.remove_self
    end
  end

  def draw(target,x_off,y_off)
    target.fill [25,25,25,255]
    for star in @stars
      target.draw_circle_s([star.x+x_off,star.y+y_off],1,[255,255,255,255])
    end
  end
end

