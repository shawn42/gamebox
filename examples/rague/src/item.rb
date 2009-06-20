require 'actor'

class Item < Actor
  has_behaviors :animated, :layered => 2

  def setup
    self.action = @opts[:name]
  end

end