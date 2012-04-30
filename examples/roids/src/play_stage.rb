class PlayStage < Stage

  # TODO make this work in conject
  # construct_with :physics_manager
  attr_accessor :physics_manager

  def setup
    super
    @physics_manager = this_object_context[:physics_manager]
    @physics_manager.configure

    sound_manager.play_music :roids

    create_actor :starry_night, :width => viewport.width, :height => viewport.height

    @physics_manager.elastic_iterations = 4

    @ship = create_actor :ship, :x => 300, :y => 300

    input_manager.reg :down, KbS do |evt|
      @ship.action = :exploding
    end

    input_manager.reg :down, KbP do |evt|
      require 'pry'
      binding.pry
    end

    score = create_actor :score, :x => 10, :y => 10
    create_actor :logo, :x => 900, :y => 600
    create_actor :fps, :x => 800, :y => 10

    input_manager.reg :down, KbR do
      fire :next_stage
    end

    @rocks = []
    opts[:rocks].times do
      rock = create_actor :rock
      @rocks << rock
      x,y = rand(400)+200,rand(300)+200
      rock.react_to :warp, vec2(x,y)
    end

    @physics_manager.damping = 0.4

    # TODO get this from screen config
    # pass it into the ship as well
    @width = 1024
    @height = 768

    # ship rock collision
    @physics_manager.add_collision_func(:rock, :ship) do |rock, ship|
      shippy = ship.actor
      unless shippy.invincible
        sound_manager.play_sound :implosion

        if shippy.alive
          shippy.remove
          explosion = create_actor :particle_system, x: shippy.x, y: shippy.y
          explosion.when :remove_me do
            fire :prev_stage
          end
        end
      end
    end

    @physics_manager.add_collision_func(:rock, :bullet) do |rock, bullet|
      sound_manager.play_sound :implosion

      rocky = rock.actor
      rocky.when :remove_me do
        score.react_to :add, 10
      end

      if rocky.alive
        rocky.remove
        x,y = rocky.x, rocky.y
        (10+rand(10)).times do
          bit = create_actor :rock_bit
          bit.react_to :warp, vec2(x,y)
        end
      end

      @rocks.delete rocky

      bullet.actor.remove
    end

    @stars = []
    20.times { @stars << vec2(rand(@width),rand(@height)) }

    @curtain = create_actor :curtain, :dir => :up, 
      :duration => 4000

    @curtain.when :curtain_up do
      curtain_up
    end

    end

  def curtain_up(*args)
    @running = true
  end

  def running?
    @running
  end

  def update(time)
    super
    return unless running?
    @physics_manager.update_physics time

    if @rocks.empty?
      @ship.when :remove_me do
        fire :next_stage
      end
      @ship.remove
    end
  end

end


