require 'actor'

class Monster < Actor
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
  end
  
  def move_up
    #puts "monster up"
  end
  
  def move_down
    #puts "monster down"
  end
  
  def move_left
    #puts "monster left"
  end
  
  def move_right
    #puts "monster right"
  end

end