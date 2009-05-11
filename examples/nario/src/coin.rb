require 'actor'

class Coin < Actor
  has_behaviors :animated,
    :layered => {:layer => 2, :parallax => 1}
  
  def setup
    self.action = :spinning
    
    # time to live in ms
    @ttl = 600
  end
  
  def update(time)
    @ttl -= time
    if @ttl <= 0
      remove_self
    end
    self.y -= time/3
    
    super time
  end
end
