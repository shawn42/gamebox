require 'helper'

class Vec
  attr_accessor :x, :y
  def initialize(x,y)
    @x = x
    @y = y
  end
end

describe Viewport do
  inject_mocks :config_manager
  before do
    @config_manager.stubs(:[]).with(:screen_resolution).returns([800, 600])
  end

  it 'should construct with width and height' do
    subject.width.should == 800
    subject.height.should == 600
    subject.x_offset.should == 0
    subject.y_offset.should == 0
  end

  describe "#stay_centered_on" do

    it 'should center the viewport on an actor when stay_centered_on' do
      actor = Vec.new 900, 200
      subject.stay_centered_on actor

      subject.x_offset.should == -500
      subject.y_offset.should == 100
      subject.follow_target.should equal(actor)
    end

    it 'should center the viewport on an actor (plus offset) when stay_centered_on' do
      actor = Vec.new 900, 200
      subject.stay_centered_on actor, x_offset: -40, y_offset: 20

      subject.x_offset.should == -460
      subject.y_offset.should == 80
      subject.follow_target.should equal(actor)
    end

    it 'should stay_centered_on a target if target has gone right;down of its buffer' do
      actor = Vec.new 900, 200
      subject.stay_centered_on actor, x_chain_length: 100, y_chain_length: 200

      subject.update 100
      actor.x = 990
      actor.y = 390

      subject.update 100
      subject.x_offset.should == -500
      subject.y_offset.should == 100

      actor.x = 1001
      actor.y = 401
      subject.update 100

      subject.x_offset.should == -501
      subject.y_offset.should == 99
    end

    it 'should stay_centered_on a target if target has gone left;up of its buffer' do
      actor = Vec.new 900, 200
      subject.expects(:fire).with(:scrolled).twice
      subject.stay_centered_on actor, x_chain_length: 100, y_chain_length: 200

      subject.update 100
      actor.x = 810
      actor.y = 10

      subject.update 100
      subject.x_offset.should == -500
      subject.y_offset.should == 100

      actor.x = 799
      actor.y = -1
      subject.update 100

      subject.x_offset.should == -499
      subject.y_offset.should == 101
    end

    it 'should respect the speed setting' do
      actor = Vec.new 900, 200
      subject.speed = 0.5
      subject.stay_centered_on actor, x_chain_length: 100, y_chain_length: 200

      subject.update 100
      actor.x = 990
      actor.y = 390

      subject.update 100
      subject.x_offset.should == -500
      subject.y_offset.should == 100

      actor.x = 1002
      actor.y = 402
      subject.update 100

      subject.x_offset.should == -501
      subject.y_offset.should == 99

    end

    it 'should fire :scrolled event when targeting an actor' do
      actor = Vec.new 900, 200
      subject.expects(:fire).with(:scrolled)
      subject.stay_centered_on actor, x_chain_length: 100, y_chain_length: 200
    end
  end

  describe "#follow" do

    it 'should center the viewport on an actor when follow' do
      actor = Vec.new 900, 200
      subject.follow actor

      subject.x_offset.should == -500
      subject.y_offset.should == 100
      subject.follow_target.should equal(actor)
    end

    it 'should center the viewport on an actor (plus offset) when follow' do
      actor = Vec.new 900, 200
      subject.follow actor, [40,-20]

      subject.x_offset.should == -460
      subject.y_offset.should == 80
      subject.follow_target.should equal(actor)
    end

    it 'should follow a target if target has gone right;down of its buffer' do
      actor = Vec.new 900, 200
      subject.follow actor, [0,0], [100,200] 

      subject.update 100
      actor.x = 990
      actor.y = 390

      subject.update 100
      subject.x_offset.should == -500
      subject.y_offset.should == 100

      actor.x = 1001
      actor.y = 401
      subject.update 100

      subject.x_offset.should == -501
      subject.y_offset.should == 99
    end

    it 'should follow a target if target has gone left;up of its buffer' do
      actor = Vec.new 900, 200
      subject.expects(:fire).with(:scrolled).twice
      subject.follow actor, [0,0], [100,200] 

      subject.update 100
      actor.x = 810
      actor.y = 10

      subject.update 100
      subject.x_offset.should == -500
      subject.y_offset.should == 100

      actor.x = 799
      actor.y = -1
      subject.update 100

      subject.x_offset.should == -499
      subject.y_offset.should == 101
    end

    it 'should respect the speed setting' do
      actor = Vec.new 900, 200
      subject.speed = 0.5
      subject.follow actor, [0,0], [100,200]

      subject.update 100
      actor.x = 990
      actor.y = 390

      subject.update 100
      subject.x_offset.should == -500
      subject.y_offset.should == 100

      actor.x = 1002
      actor.y = 402
      subject.update 100

      subject.x_offset.should == -501
      subject.y_offset.should == 99

    end

    it 'should fire :scrolled event when targeting an actor' do
      actor = Vec.new 900, 200
      subject.expects(:fire).with(:scrolled)
      subject.follow actor, [0,0], [100,200] 
    end

  end

  it 'enforces speed is >= 0 and <= 1' do
    subject.speed.should == 1

    subject.speed = 0
    subject.speed.should == 0

    subject.speed = 2
    subject.speed.should == 1

    subject.speed = 0.1
    subject.speed.should be_within(0.001).of(0.1)
  end

  it 'should respect parallax scrolling layers for offsets' do
    subject.x_offset = -200
    subject.y_offset = -300

    subject.x_offset(2).should == -100
    subject.y_offset(2).should == -150
  end

  it 'should return a zero offset on INFINITY' do
    subject.x_offset = -200
    subject.y_offset = -300

    subject.x_offset(Float::INFINITY).should == 0
    subject.y_offset(Float::INFINITY).should == 0
  end

  it "shouldn't update anything unless following a target" do
    subject.x_offset = -200
    subject.y_offset = -300

    subject.update 3000

    subject.x_offset.should == -200
    subject.y_offset.should == -300
  end

  describe "#bounds" do
    it 'returns the bounds as [x1,y1,x2,y2]' do
      subject.bounds.should == [0,0,800,600]

      subject.x_offset = -10
      subject.y_offset = -100

      bounds = subject.bounds
      bounds.left.should == 10
      bounds.top.should == 100
      bounds.width.should == 800
      bounds.height.should == 600
    end
  end

end
