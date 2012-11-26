define_stage :play do

  requires :physics_manager

  setup do
    physics_manager.configure
    physics_manager.damping = 0.4

    sound_manager.play_music :roids

    create_actor :starry_night, :width => viewport.width, :height => viewport.height

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

    backstage[:level] ||= 0
    backstage[:level] += 1

    @rocks = []
    rocks_per_level[backstage[:level] - 1].times do
      rock = create_actor :rock
      @rocks << rock
      x,y = rand(400)+200,rand(300)+200
      rock.react_to :warp, vec2(x,y)
    end


    # TODO get this from screen config
    # pass it into the ship as well
    @width = 1024
    @height = 768

    # ship rock collision
    physics_manager.add_collision_func(:rock, :ship) do |rock, ship|
      unless ship.invincible
        sound_manager.play_sound :implosion

        if ship.alive
          ship.remove
          explosion = create_actor :particle_system, x: ship.x, y: ship.y
          explosion.when :remove_me do
            fire :prev_stage
          end
        end
      end
    end

    physics_manager.add_collision_func(:rock, :bullet) do |rock, bullet|
      sound_manager.play_sound :implosion

      rock.when :remove_me do
        score.react_to :add, 10
      end

      if rock.alive
        rock.remove
        x,y = rock.x, rock.y
        (10+rand(10)).times do
          bit = create_actor :rock_bit
          bit.react_to :warp, vec2(x,y)
        end
      end

      @rocks.delete rock
      bullet.remove
    end

    @stars = []
    20.times { @stars << vec2(rand(@width),rand(@height)) }

    @curtain = create_actor :curtain, :dir => :up, 
      :duration => 4000

    @curtain.when :curtain_up do
      curtain_up
    end

    director.when :update do |time|

      return unless running?
      physics_manager.update_physics time

      if @rocks.empty?
        @ship.when :remove_me do
          if last_level?
            fire :change_stage, :credits
          else
            fire :restart_stage
          end
        end
        @ship.remove
      end
    end

  end

  helpers do
    def last_level?
      backstage[:level] == (rocks_per_level.size)
    end

    def rocks_per_level
      [4, 6, 9]
    end

    def curtain_up(*args)
      @running = true
    end

    def running?
      @running
    end

  end
end


