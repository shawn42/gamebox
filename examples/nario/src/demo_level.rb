require 'physical_level'
require 'physical_director'
class DemoLevel < PhysicalLevel
  def setup
    @sound_manager.play :overworld
      
    @space.gravity = vec2(0,800)
    @space.iterations = 10

    @score = create_actor :score, :x => 10, :y => 10
    create_actor :logo, :x => 10, :y => 660


    mid = create_actor :nario_mid, :x => 10, :y => 170

    ground = create_actor :ground, :x => 0, :y => 670
    ground.shape.e = 0 #0.0004
    ground.shape.u = 0.9 #0.0004

    create_actor :coin, :x => 200, :y => 630

    pup = create_actor :power_up_block, :x => 500, :y => 550

    @nario = create_actor :nario, :x => 400, :y => 620

    @viewport.follow @nario, [0,70], [300,400]

    bg = create_actor :nario_background
    @space.add_collision_func(:coin, :nario) do |c,n|
      coin = @director.find_physical_obj c
      unless coin.dying?
        coin.die 400
        @score += 10
        create_actor :coin, :x => (200+rand(400)), :y => 100
      end
    end

    @space.add_collision_func([:ground,:power_up_block], :nario_feet) do |ground_like_obj,nf|
      # p 'feet collided w/ ground like obj'
      @nario.stop_jump
    end
    @space.add_collision_func(:power_up_block, :nario_hat) do |pup,n|
      # p "nario hit block"
      pup_obj = @director.find_physical_obj pup
      if pup_obj.active?
        @nario.stop_jump
        pup_obj.hit
        @score += 10
      end
    end

    @nario.instance_variable_get('@input_manager').reg KeyDownEvent, K_P do
      p @viewport.debug
      p @nario.debug
    end

  end

  def draw(target,x_off,y_off)
    target.fill [25,25,25,255]
  end
end

