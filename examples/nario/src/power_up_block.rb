require 'actor'

class PowerUpBlock < Actor
  HIT_RATE = 500

  has_behaviors :graphical, {:physical => {
    :shape => :poly,
    :fixed => true,
    :friction => 0.6,
    :verts => [[-30,-30],[-30,30],[30,30],[30,-30]]
  }}, 
    {:layered => {:layer => 2, :parallax => 1}}

  def setup
    @inactive_timer = 0
    @active = true
  end

  # the block can only be hit onces every HIT_RATE ms
  def hit
    spawn :coin, :x => x, :y => y-20, :ttl => 600

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
