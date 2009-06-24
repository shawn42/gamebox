require 'behavior'
class Wanderer < Behavior
  def setup
    @dirs = [:up,:down,:left,:right]
    pick_random_dir
  end
  
  def pick_random_dir
    @dir = @dirs[rand(@dirs.size)]
  end
  
  def update(time)
    # move dir
    @actor.send "move_#{@dir}".to_sym
    
    pick_random_dir
  end
end