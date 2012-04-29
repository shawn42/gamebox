ActorView.define :curtain_view do
  draw do |target,x_off,y_off,z|
    target.fill 0,0,1024,800, [0,0,0,actor.height], z
  end
end

FULL_CURTAIN = 255
NO_CURTAIN = 0

Behavior.define :curtain_operator do
  requires :director
  setup do
    actor.has_attributes duration_in_ms: 1000
    actor.has_attributes dir: :down

    case actor.dir
    when :up
      height = FULL_CURTAIN
      actor.dir = -1
    when :down
      height = NO_CURTAIN
      actor.dir = 1
    end

    actor.has_attributes height: height
    director.when :update do |time|
      update time
    end
  end

  helpers do
    # Update curtain height 0-255 (alpha)
    def update(time)
      perc_change = time.to_f/actor.duration_in_ms
      amount = FULL_CURTAIN * perc_change * actor.dir
      actor.height += amount.floor

      if actor.height < 0
        actor.height = 0
        if actor.alive
          actor.emit :curtain_up
          actor.remove
        end
      elsif actor.height > 255
        actor.height = 255
        if actor.alive
          actor.emit :curtain_down
          actor.remove
        end
      end
    end
  end
end

Actor.define :curtain do
  has_behavior layered: 99_999
  has_behavior :curtain_operator
end
