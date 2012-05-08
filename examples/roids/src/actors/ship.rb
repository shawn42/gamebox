# use one big behavior for now..
define_behavior :shiplike do
  requires :director, :stage, :input_manager
  setup do
    actor.has_attributes invincible: 2000
    @speed = 300
    @turn_speed = 0.0045
    @max_speed = 500

    i = input_manager
    i.reg :down, KbSpace do
      shoot
    end
    i.reg :down, KbRightControl, KbLeftControl do
      actor.react_to :warp, vec2(rand(400)+100,rand(400)+100)
    end
    i.reg :down, KbLeft do
      @moving_left = true
    end
    i.reg :down, KbRight do
      @moving_right = true
    end
    i.reg :down, KbUp do
      @moving_forward = true
      actor.action = :thrust
    end
    i.reg :up, KbLeft do
      @moving_left = false
    end
    i.reg :up, KbRight do
      @moving_right = false
    end
    i.reg :up, KbUp do
      @moving_forward = false
      actor.action = :idle
    end

    # TODO do this automagically?
    actor.when :remove_me do
      puts "CLEARING"
      i.clear_hooks self
    end

    director.when :update do |time|
      update time
    end
  end

  helpers do
    def moving_forward?;@moving_forward;end
    def moving_left?;@moving_left;end
    def moving_right?;@moving_right;end

    def update(time)
      if actor.invincible && actor.invincible > 0
        actor.invincible -= time
      else
        actor.invincible = false
      end
      actor.body.reset_forces
      move_forward time if moving_forward?
      move_left time if moving_left?
      move_right time if moving_right?
      actor.body.p = CP::Vec2.new(actor.body.p.x % 1024, actor.body.p.y % 768)
    end

    def shoot
      bullet = stage.create_actor :bullet
      bullet.react_to :warp, vec2(actor.x,actor.y)+vec2(actor.body.rot.x,actor.body.rot.y).normalize*30
      bullet.body.a += actor.body.a
      bullet.dir = vec2(actor.body.rot.x,actor.body.rot.y)
      actor.react_to :play_sound, :laser
    end

    def move_right(time)
      actor.body.t += 100.0 * time
    end

    def move_left(time)
      actor.body.t -= 100.0 * time
    end

    def move_forward(time)
      val = actor.body.a
      move_vec = CP::Vec2.new(Math::cos(val), Math::sin(val)) * time * @speed

      actor.body.apply_force(move_vec, ZERO_VEC_2) 
    end
  end
end

define_actor :ship do

  has_behavior :shiplike, :audible, :animated, :physical => {:shape => :circle, 
    :mass => 10,
    :friction => 1.7,
    :elasticity => 0.4,
    :radius => 10,
    :moment => 150 
  }

end
