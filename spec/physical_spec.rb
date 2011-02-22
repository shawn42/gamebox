require File.join(File.dirname(__FILE__),'helper')

class CircleActor < Actor
  has_behaviors :physical => {:shape => :circle, 
    :mass => 500,
    :radius => 10}
end

describe 'A new physical behavior' do
  before do
    @stage = stub(:load_animation_set => ['1.png_img_obj','2.png_img_obj'],:register_physical_object => true)

    @opts = {:stage=>@stage, :input=>"input", :resources=>"rm"}
    @actor = CircleActor.new @opts
    @physical = @actor.physical
  end

  it 'should add methods to its actor' do
    @actor.should.respond_to? :x
    pending 'add shared example for relegates'
  end

  describe "#pivot" do
    it 'creates a new PivotJoint and adds it to the space' do
      other = CircleActor.new @opts
      v1 = vec2(2,3)
      v2 = vec2(4,5)
      CP::Constraint::PivotJoint.expects(:new).with(@physical.body, other.body, v1, v2).returns(:joint)
      @stage.expects(:register_physical_constraint).with(:joint)

      @actor.pivot(v1, other, v2).should == :joint
    end
  end

  describe "#pin" do
    it 'creates a new PinJoint and adds it to the space' do
      other = CircleActor.new @opts
      v1 = vec2(2,3)
      v2 = vec2(4,5)
      CP::Constraint::PinJoint.expects(:new).with(@physical.body, other.body, v1, v2).returns(:joint)
      @stage.expects(:register_physical_constraint).with(:joint)

      @actor.pin(v1, other, v2).should == :joint
    end
  end

  describe "#spring" do
    it 'creates a new DampedSpring and adds it to the space' do
      other = CircleActor.new @opts
      v1 = vec2(2,3)
      v2 = vec2(4,5)
      CP::Constraint::DampedSpring.expects(:new).with(@physical.body, other.body, v1, v2, 1,2,3).returns(:spring)
      @stage.expects(:register_physical_constraint).with(:spring)

      @actor.spring(v1, other, v2, 1, 2, 3).should == :spring
    end
  end

  describe "#slide" do
    it 'creates a new SlideJoint and adds it to the space' do
      other = CircleActor.new @opts
      v1 = vec2(2,3)
      v2 = vec2(4,5)
      CP::Constraint::SlideJoint.expects(:new).with(@physical.body, other.body, v1, v2, 2,4).returns(:slide)
      @stage.expects(:register_physical_constraint).with(:slide)

      @actor.slide(v1, other.body, v2, 2, 4).should == :slide
    end
  end

  describe "#groove" do
    it 'creates a new GrooveJoint and adds it to the space' do
      other = CircleActor.new @opts
      v1 = vec2(2,3)
      v2 = vec2(4,5)
      v3 = vec2(9,7)
      CP::Constraint::GrooveJoint.expects(:new).with(@physical.body, other.body, v1, v2, v3).returns(:groove)
      @stage.expects(:register_physical_constraint).with(:groove)

      @actor.groove(v1, v2, other.body, v3).should == :groove
    end
  end

  describe "#rotary_spring" do
    it 'creates a new DampedRotarySpring and adds it to the space' do
      other = CircleActor.new @opts
      CP::Constraint::DampedRotarySpring.expects(:new).with(@physical.body, other.body, 3.14, 10, 50).returns(:rotary_spring)
      @stage.expects(:register_physical_constraint).with(:rotary_spring)
      @actor.rotary_spring(other.body, 3.14, 10, 50).should == :rotary_spring
    end
  end

  describe "#rotary_limit" do
    it 'creates a new RotaryLimitJoint and adds it to the space' do
      other = CircleActor.new @opts
      CP::Constraint::RotaryLimitJoint.expects(:new).with(@physical.body, other.body, 0, 3).returns(:rotary_limit)
      @stage.expects(:register_physical_constraint).with(:rotary_limit)
      @actor.rotary_limit(other.body, 0, 3).should == :rotary_limit
    end
  end

  describe "#ratchet" do
    it 'creates a new RatchetJoint and adds it to the space' do
      other = CircleActor.new @opts
      CP::Constraint::RatchetJoint.expects(:new).with(@physical.body, other.body, 0, 0.3).returns(:ratchet)
      @stage.expects(:register_physical_constraint).with(:ratchet)
      @actor.ratchet(other.body, 0, 0.3).should == :ratchet
    end
  end

  describe "#gear" do
    it 'creates a new GearJoint and adds it to the space' do
      other = CircleActor.new @opts
      CP::Constraint::GearJoint.expects(:new).with(@physical.body, other.body, 0, 0.3).returns(:gear)
      @stage.expects(:register_physical_constraint).with(:gear)
      @actor.gear(other.body, 0, 0.3).should == :gear
    end
  end

  describe "#motor" do
    it 'creates a new SimpleMotor and adds it to the space' do
      other = CircleActor.new @opts
      CP::Constraint::SimpleMotor.expects(:new).with(@physical.body, other.body, 40).returns(:motor)
      @stage.expects(:register_physical_constraint).with(:motor)
      @actor.motor(other.body, 40).should == :motor
    end
  end

end
