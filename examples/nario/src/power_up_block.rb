require 'actor'
require 'animated_actor_view'

class PowerUpBlockView < AnimatedActorView
end

class PowerUpBlock < Actor
  HIT_RATE = 500

  has_behaviors :graphical, {:physical => {
    :shape => :poly,
    :fixed => true,
    :verts => [[-30,-30],[-30,30],[30,30],[30,-30]]
  }}, 
    {:layered => {:layer => 2, :parallax => 2}}

  def setup
    @inactive_timer = 0
    @active = true
  end

  # the block can only be hit onces every HIT_RATE ms
  def hit
    p "nario hit the powerup block" 
    @active = false
    @inactive_timer = HIT_RATE if has_more?
  end

  def active?
    @active
  end

  def has_more?
    true
  end

  def update(time)
    if @inactive_timer > 0
      @inactive_timer -= time
      @active = true if @inactive_timer <= 0
    end
  end
end
