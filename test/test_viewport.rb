require 'helper'
require 'viewport'

class Vec
  attr_accessor :x, :y
  def initialize(x,y)
    @x = x
    @y = y
  end
end

describe 'A new viewport' do
  before do
    @viewport = Viewport.new 800, 600
  end

  it 'should construct with width and height' do
    @viewport.width.should == 800
    @viewport.height.should == 600
    @viewport.x_offset.should == 0
    @viewport.y_offset.should == 0
  end
  
  it 'should center the viewport on an actor when follow' do
    actor = Vec.new 900, 200
    @viewport.follow actor
    
    @viewport.x_offset.should == -500
    @viewport.y_offset.should == 100
    @viewport.follow_target.should == actor
  end
  
  it 'should center the viewport on an actor (plus offset) when follow' do
    actor = Vec.new 900, 200
    @viewport.follow actor, [40,-20]
    
    @viewport.x_offset.should == -460
    @viewport.y_offset.should == 80
    @viewport.follow_target.should == actor
  end
  
  it 'should respect parallax scrolling layers for offsets' do
    @viewport.x_offset = -200
    @viewport.y_offset = -300
    
    @viewport.x_offset(2).should == -100
    @viewport.y_offset(2).should == -150
  end

  it 'should return a zero offset on Infinity' do
    @viewport.x_offset = -200
    @viewport.y_offset = -300
    
    @viewport.x_offset(Float::Infinity).should == 0
    @viewport.y_offset(Float::Infinity).should == 0
  end
  
  it 'shouldn\'t update anything unless following a target' do
    @viewport.x_offset = -200
    @viewport.y_offset = -300
    
    @viewport.update 3000
    
    @viewport.x_offset.should == -200
    @viewport.y_offset.should == -300
  end
  
  it 'should follow a target if target has gone right;down of its buffer' do
    actor = Vec.new 900, 200
    @viewport.follow actor, [0,0], [100,200] 
    
    @viewport.update 100
    actor.x = 990
    actor.y = 390
    
    @viewport.update 100
    @viewport.x_offset.should == -500
    @viewport.y_offset.should == 100
    
    actor.x = 1001
    actor.y = 401
    @viewport.update 100
    
    @viewport.x_offset.should == -501
    @viewport.y_offset.should == 99
  end
  
  it 'should follow a target if target has gone left;up of its buffer' do
    actor = Vec.new 900, 200
    @viewport.follow actor, [0,0], [100,200] 
    
    @viewport.update 100
    actor.x = 810
    actor.y = 10
    
    @viewport.update 100
    @viewport.x_offset.should == -500
    @viewport.y_offset.should == 100
    
    actor.x = 799
    actor.y = -1
    @viewport.update 100
    
    @viewport.x_offset.should == -499
    @viewport.y_offset.should == 101
  end
  
  it 'should fire :scrolled event when targeting an actor' do
    fail 'finish'
  end
  
  it 'should fire :scrolled event from update when the actor moves' do
    fail 'finish'
  end

end
