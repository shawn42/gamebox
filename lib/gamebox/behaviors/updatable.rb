require 'behavior'

class Updatable < Behavior
  
  def setup
    @actor.director.add_actor @actor
  end
end
