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

end
