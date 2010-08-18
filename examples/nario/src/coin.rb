require 'actor'

class Coin < Actor
  has_behaviors :audible, :animated, :updatable, {:collidable => {:shape => :circle, :radius => 15} },
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
    @y -= 10
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
