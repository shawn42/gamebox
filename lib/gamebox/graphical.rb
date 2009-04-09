require 'behavior'
# keeps track of an image for you based on the actor's class
# by default it expects images to be:
# data/graphics/classname.png
class Graphical < Behavior

  attr_accessor :image
  def setup

    @image = @actor.resource_manager.load_actor_image @actor

    graphical_obj = self
    @actor.instance_eval do
      (class << self; self; end).class_eval do
        define_method :image do 
          graphical_obj.image
        end
        define_method :graphical do 
          graphical_obj
        end
      end
    end
  end
end
