

class BoxShooter < Actor

  has_behaviors :updatable

  def setup
    @last_shot = 4000
  end

  def update(delta)
    if @last_shot > 500 
      @last_shot = 0
      shoot_box
    end

    @last_shot += delta
  end

  def shoot_box
    box = spawn :box, :x => @x, :y => @y
    box.body.apply_impulse vec2(500, -700), ZERO_VEC_2
  end

end
