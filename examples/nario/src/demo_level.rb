require 'physical_level'
require 'physical_director'
class DemoLevel < PhysicalLevel
  def setup
    @space.gravity = vec2(0,800)
    @space.iterations = 10

    mid = create_actor :nario_mid, :x => 10, :y => 215

    ground = create_actor :ground, :x => 0, :y => 670
    ground.shape.e = 0 #0.0004
    ground.shape.u = 1 #0.0004


    pup = create_actor :power_up_block, :x => 500, :y => 550

    @nario = create_actor :nario, :x => 400, :y => 620

    @viewport.follow @nario, [0,70], [100,60]

    bg = create_actor :nario_background

    @space.add_collision_func([:ground,:power_up_block], :nario_feet) do |ground_like_obj,nf|
      # p 'feet collided w/ ground like obj'
      @nario.stop_jump
    end
    @space.add_collision_func(:power_up_block, :nario_hat) do |pup,n|
      p "nario hit block"
      pup_obj = @director.find_physical_obj pup
      if pup_obj.active?
        @nario.stop_jump
        pup_obj.hit
      end
    end

  end

  def draw(target,x_off,y_off)
    target.fill [25,25,25,255]
  end
end

