# TODO how to specify that animated means graphical actor view?
# TODO ivars in behaviors? frowned upon?

define_behavior :rocky do
  requires :director
  setup do
    actor.has_attributes view: 'graphical_actor_view'
    actor.body.a -= rand(10)
    @speed = (rand(2)+1) * 20
    @turn_speed = rand(2)*0.0004 
    @dir = vec2(rand-0.5,rand-0.5)

    director.when :update do |time|
      update time
    end
  end

  helpers do
    def update(time)
      actor.body.reset_forces

      actor.body.p = CP::Vec2.new(actor.body.p.x % 1024, actor.body.p.y % 768)
      actor.body.w += time*@turn_speed

      move_vec = @dir * time * @speed

      actor.body.apply_force(move_vec, ZERO_VEC_2) 
    end
  end

end

class CP::Shape::Circle
  attr_accessor :actor
end

define_actor :rock do
  has_behaviors :animated, :physical => {:shape => :circle, 
    :mass => 10,
    :radius => 20}
  # TODO rocky needs to come _after_ physical, how do I enforce that?
  has_behaviors :rocky
end
