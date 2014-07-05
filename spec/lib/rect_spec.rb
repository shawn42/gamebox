require 'helper'

describe Rect do  
  describe "#collide_rect?" do
    subject { Rect.new 0,0,3,4 }

    it 'finds collisions' do
      collides_with(0,0,3,4)
      collides_with(1,0,3,4)
      collides_with(0,1,3,4)
      collides_with(1,1,2,3)

      does_not_collide_with(4,5,2,3)
      does_not_collide_with(-2,-2,1,1)
      does_not_collide_with(-2,2,1,1)
    end

    private
    def collides_with(x,y,w,h)
      subject.collide_rect?(Rect.new(x,y,w,h)).should be_true
    end

    def does_not_collide_with(x,y,w,h)
      subject.collide_rect?(Rect.new(x,y,w,h)).should be_false
    end
  end
  
end
