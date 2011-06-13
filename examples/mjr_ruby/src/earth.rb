class EarthView < GraphicalActorView

  def draw(target, x_off, y_off, z)
    x = @actor.x
    y = @actor.y

    img = @actor.image
    w,h = img.width, img.height
#    x = x-w/2
#    y = y-h/2
    img.draw x+x_off, y+y_off, z

    target.screen.draw_box_s [x+x_off,y+y_off], [x+x_off+w,y+y_off+h], [40,40,40,100] if @actor.is? :fading
  end
end
class Earth < Actor
  has_behavior :graphical, :layered 
end
