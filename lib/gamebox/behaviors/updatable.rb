

class Updatable < Behavior
  
  def setup
    @actor.director.add_actor @actor
  end

  def removed
    @actor.director.remove_actor @actor
  end
end
