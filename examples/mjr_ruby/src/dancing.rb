require 'behavior'

# makes the actor 'dance' in place
class Dancing < Behavior

  attr_accessor :rotation, :orig_x, :orig_y, :orig_w
  def setup
    @orig_w, @orig_y = *@actor.image.size
    dist = 20
    @rot_array = [*-dist..dist]
    @rot_array += @rot_array.reverse
    @count = 0
    @rotation = 0

    dancer = self
    @actor.instance_eval do
      (class << self; self; end).class_eval do
        define_method :rotation do 
          dancer.rotation
        end
        define_method :orig_w do
          dancer.orig_w
        end
      end
    end
  end

  # rotate
  def update(time_delta)
    @count %= @rot_array.size
    @rotation = @rot_array[@count]
    @count += 3
  end

end
