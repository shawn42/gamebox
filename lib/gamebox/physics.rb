require 'chipmunk'

require 'numbers_ext'
include CP
ZERO_VEC_2 = vec2(0,0)

class Space
  alias :add_collision_func_old :add_collision_func
  
  # allows for passing arrays of collision types not just single ones
  # add_collision_func([:foo,:bar], [:baz,:yar]) becomes:
  # add_collision_func(:foo, :baz)
  # add_collision_func(:foo, :yar)
  # add_collision_func(:bar, :baz)
  # add_collision_func(:bar, :yar)
  def add_collision_func(first_objs, second_objs, &block)
    firsts = [first_objs].flatten
    seconds = [second_objs].flatten
    
    firsts.each do |f|
      seconds.each do |s|
        add_collision_func_old(f,s,&block)
      end
    end
  end

end
