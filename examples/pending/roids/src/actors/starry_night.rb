define_behavior :starfield do
  requires :director
  setup do
    actor.has_attributes stars: []
    20.times { actor.stars << [rand(actor.width), rand(actor.height), rand/5.0] }

    director.when :update do |time|
      actor.stars.each do |star| 
        star[1] = (star[1] + star[2] * time) % actor.height
      end
    end
  end
end

define_actor :starry_night do
  has_behavior :starfield, layered: -1

  view do
    setup do
      @color = [255,255,255,255]
    end
    draw do |target, x_off, y_off, z|
      for star in actor.stars
        target.draw_circle_filled(star[0], star[1], 1, @color, z)
      end
    end
  end
end
