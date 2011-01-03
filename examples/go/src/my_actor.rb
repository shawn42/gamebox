


#class MyActorView < ActorView
#  def draw(target, x_off, y_off)
#    x = @actor.x
#    y = @actor.y
#    target.draw_box x,y, x+20,y+20, [240,45,45,255]
#  end
#end

class MyActor < Actor

  has_behavior :updatable, :graphical, :audible
  attr_accessor :move_left, :move_right, :move_up, :move_down
  def setup
    input_manager.reg :mouse_motion do |evt|
      puts evt[:data]
    end
    input_manager.reg :mouse_down do 
      play_sound :laser
    end
    input_manager.while_key_pressed KbLeft, self, :move_left
    input_manager.while_key_pressed KbRight, self, :move_right
    input_manager.while_key_pressed KbUp, self, :move_up
    input_manager.while_key_pressed KbDown, self, :move_down
  end

  def update(time_delta)
    @speed = time_delta * 0.1
    @x += @speed if move_right
    @x -= @speed if move_left
    @y -= @speed if move_up
    @y += @speed if move_down
  end

end
