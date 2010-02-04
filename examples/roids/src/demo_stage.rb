require 'physical_stage'

class DemoStage < PhysicalStage

  def setup
    super
    sound_manager.play_music :roids

    create_actor :starry_night, :width => viewport.width, :height => viewport.height

    space.elastic_iterations = 4

    @ship = create_actor :ship, :x => 300, :y => 300

    input_manager.reg KeyDownEvent, K_S do |evt|
      @ship.action = :exploding
    end
    score = create_actor :score, :x => 10, :y => 10
    create_actor :logo, :x => 900, :y => 600

    @rocks = []
    opts[:rocks].times do
      rock = create_actor :rock
      @rocks << rock
      x,y = rand(400)+200,rand(300)+200
      rock.warp vec2(x,y)
    end

    space.damping = 0.4

    # TODO get this from screen config
    @width = 1024
    @height = 768

    # ship rock collision
    space.add_collision_func(:rock, :ship) do |rock, ship|
      shippy = director.find_physical_obj ship
      unless shippy.invincible?
        sound_manager.play_sound :implosion

        if shippy.alive?
          explosion = create_actor :particle_system, :x => shippy.x, :y => shippy.y
          explosion.when :remove_me do
            fire :prev_stage
          end
          shippy.remove_self 
        end
      end
    end

    space.add_collision_func(:rock, :bullet) do |rock, bullet|
      sound_manager.play_sound :implosion

      rocky = director.find_physical_obj rock
      rocky.when :remove_me do
        score += 10
      end

      if rocky.alive?
        rocky.remove_self 
        x,y = rocky.x, rocky.y
        (10+rand(10)).times do
          bit = create_actor :rock_bit
          bit.warp vec2(x,y)
        end
      end

      @rocks.delete rocky

      director.remove_physical_obj bullet
    end

    @stars = []
    20.times { @stars << vec2(rand(@width),rand(@height)) }

    @curtain = create_actor :curtain, :dir => :up, 
      :duration => 4000

    @curtain.when :curtain_up do
      curtain_up
    end

  end

  def curtain_up
    @running = true
  end

  def running?
    @running
  end

  def update(time)
    # TODO where to put this?
    # actors can be :pausable 
    # directors have two lists and not update the pausable list
    # if paused
    @curtain.update time if @curtain

    super
    return unless running?
    update_physics time
    director.update time

    if @rocks.empty?
      @ship.when :remove_me do
        fire :next_stage
      end
      @ship.remove_self
    end
  end

  def draw(target)
    target.fill [25,25,25,255]
    super
  end
end

