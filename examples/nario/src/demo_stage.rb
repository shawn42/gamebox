require 'physical_stage'

class DemoStage < PhysicalStage
  
  def setup
    super
    sound_manager.play_music :overworld

    @svg_doc = resource_manager.load_svg @opts[:file]
      
    space.gravity = vec2(0,1800)
    space.iterations = 10

    @score = create_actor :score, :x => 10, :y => 10
    create_actor :logo, :x => 10, :y => 660

    dynamic_actors = create_actors_from_svg @svg_doc

    create_actor :svg_actor, :name => :ground, :svg_doc => @svg_doc
    create_actor :svg_actor, :name => :death_zone, :svg_doc => @svg_doc, :hide => true

    @nario = dynamic_actors[:nario]
    viewport.follow @nario, [0,70], [200,100]

    on_collision_of :nario, :coin do |nario, coin|
      unless coin.dying?
        coin.collect
        @score += 10
        spawn :coin, :x => (200+rand(400)), :y => nario.y
      end
    end

    space.add_collision_func(:coin, [:nario,:nario_feet,:nario_hat]) do |c,n|
      coin = director.find_physical_obj c
      unless coin.dying?
        coin.collect
        @score += 10
        create_actor :coin, :x => (200+rand(400)), :y => 100
      end
    end
    
    space.add_collision_func(:death_zone, [:nario,:nario_feet,:nario_hat]) do |d,n|
      unless @nario.dying?
        @nario.die
        sound_manager.stop_music :overworld
        pause_physics
        Thread.new do
          sleep 4
          fire :restart_stage
        end
      end
    end

    space.add_collision_func(:goomba, [:nario, :nario_hat]) do |g,n|
      goomba = director.find_physical_obj g
      unless goomba.dying?
        unless @nario.dying?
          @nario.die
          sound_manager.stop_music :overworld
          pause_physics
          Thread.new do
            sleep 4
            fire :restart_stage
          end
        end
      end
    end
    
    space.add_collision_func(:goomba, :nario_feet) do |g,n|
      goomba = director.find_physical_obj g
      unless goomba.dying?
        goomba.die
        sound_manager.play_sound :nario_stomp
        @score += 50
      end
    end

    space.add_collision_func(:death_zone, [:coin,:goomba]) do |d,c|
      coin = director.find_physical_obj c
      coin.die
    end
    
    space.add_collision_func([:nario,:nario_feet,:nario_hat],:flag) do |n,f|
      flag = director.find_physical_obj f
      @score += 100 # for the flag
      @score += @score.score if @nario.y < flag.y
      puts "YOU WIN! #{@score.score}"
      sound_manager.stop_music :overworld
      sound_manager.play_sound :finish_stage
      # maybe pause phsyics and game loop?
      sleep 6
      fire :next_stage
    end

    space.add_collision_func([:ground,:power_up_block], :nario_feet) do |ground_like_obj,nf|
      @nario.stop_jump
    end
    
    space.add_collision_func(:power_up_block, :nario_hat) do |pup,n|
      pup_obj = director.find_physical_obj pup
      if pup_obj.active?
        @nario.stop_jump
        pup_obj.hit
        @score += 10
      end
    end

    input_manager.reg KeyPressed, :p do
      p viewport.debug
      p @nario.debug
    end

    restart_physics
  end

  def stop(*args)
    input_manager.unreg KeyPressed, :p
  end

  def draw(target)
    target.fill [25,25,25,255]
    super
  end
end

