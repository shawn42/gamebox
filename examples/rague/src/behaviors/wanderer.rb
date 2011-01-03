
class Wanderer < Behavior
  def setup
    @dirs = [:up,:down,:left,:right,nil]
    pick_random_dir
  end
  
  def pick_random_dir
    @dir = @dirs[rand(@dirs.size)]
  end
  
  def update(time)
    # move dir
    @actor.send "move_#{@dir}".to_sym if @dir
    pick_random_dir
  end
end