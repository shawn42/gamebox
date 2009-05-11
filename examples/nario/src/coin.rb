require 'actor'

class Coin < Actor
  has_behaviors :animated, {:physical => {
      :shape => :circle,
      :mass => 1,
      :radius => 20    
    }},
    :layered => {:layer => 2, :parallax => 1}
  
  def setup
    # time to live in ms
    ttl = @opts[:ttl]
    die ttl if ttl
  end
  
  def die(ttl)
    @ttl = ttl
    play_sound :coin
    self.action = :spinning
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
