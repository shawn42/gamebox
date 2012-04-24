ActorView.define :curtain_view do
  draw do |target,x_off,y_off,z|
    target.fill 0,0,1024,800, [0,0,0,actor.height], z
  end
end

Behavior.define :curtain_operator do
  requires :director
  setup do
    @duration_in_ms = actor.opts[:duration]
    @duration_in_ms ||= 1000

    case actor.opts[:dir]
    when :up
      height = FULL_CURTAIN
      @dir = -1
    when :down
      height = NO_CURTAIN
      @dir = 1
    end

    actor.has_attributes height: height
    director.when :update do |time|
      update time
    end
  end

  helpers do
    FULL_CURTAIN = 255
    NO_CURTAIN = 0

    # Update curtain height 0-255 (alpha)
    def update(time)
      perc_change = time.to_f/@duration_in_ms
      amount = FULL_CURTAIN * perc_change * @dir
      actor.height += amount.floor

      if actor.height < 0
        actor.height = 0
        if actor.alive?
          actor.emit :curtain_up
          actor.remove
        end
      elsif actor.height > 255
        actor.height = 255
        if actor.alive?
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
