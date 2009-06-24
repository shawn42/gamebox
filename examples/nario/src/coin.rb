require 'actor'

class Coin < Actor
  has_behaviors :animated, :updatable, {:physical => {
      :shape => :circle,
      :mass => 1,
      :radius => 15,
      :angle => -1.57079633 # -90 degrees
    }},
    :layered => {:layer => 2, :parallax => 1}
  
  def setup
    # time to live in ms
    ttl = @opts[:ttl]
    die ttl if ttl
  end
  
  def collect
    die 400
    play_sound :coin
    self.action = :spinning
  end
  
  def die(ttl=0)
    @ttl = ttl
    body.apply_impulse(vec2(0,-400), ZeroVec2)
  end
  
  def dying?;@ttl;end
  
  def update(time)
    if dying?
      @ttl -= time
      if @ttl <= 0
        remove_self
      end
    end
    super time
  end
end
