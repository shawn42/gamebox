require 'actor'
require 'publisher'

class Monster < Actor
  extend Publisher
  attr_accessor :location
  has_behaviors :animated, :layered => 2

  def setup
    name = @opts[:name]
    self.action = name
    
    # TODO pull this into external file
    @hard_coded = {}
    goblin_def = {}
    behaviors = []
    behaviors << :wanderer
    goblin_def[:behaviors] = behaviors
    @hard_coded[:goblin] = goblin_def
    
    monster_def = @hard_coded[name]
    unless monster_def.nil?
      monster_def[:behaviors].each do |b|
        is b
      end
    end
    is_no_longer :updatable
  end
  
  def move_up
    fire :move_up
  end
  
  def move_down
    fire :move_down
  end
  
  def move_left
    fire :move_left
  end
  
  def move_right
    fire :move_right
  end

end
