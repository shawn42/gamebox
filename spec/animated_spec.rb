require File.join(File.dirname(__FILE__),'helper')

describe Animated do
  subject { 
    mocks = create_mocks *Animated.object_definition.component_names
    @actor = create_actor
    mocks[:actor] = @actor
    @director.stubs(:when)
    @resource_manager.stubs(:load_animation_set).returns(images)
    Animated.new(mocks).tap do |anim|
      anim.configure
      anim.action_changed nil, :idle
    end
  }
  let(:image1) { stub('image 1', width: 5, height: 6) }
  let(:image2) { stub('image 2', width: 7, height: 8) }
  let(:images) { [image1, image2] }

  it 'should define attributes on @actor' do
    subject
    @actor.has_attribute?(:image).should be_true
    @actor.has_attribute?(:action).should be_true
    @actor.has_attribute?(:width).should be_true
    @actor.has_attribute?(:height).should be_true
    @actor.has_attribute?(:image=).should be_true
    @actor.has_attribute?(:action=).should be_true
    @actor.has_attribute?(:height=).should be_true
  end

  it 'shouldnt update frame for non-animating' do
    subject.stop_animating

    subject.update subject.frame_update_time+1

    subject.frame_time.should equal(0)
    subject.frame_num.should equal(0)
  end

  it 'should update frame for animating' do
    time_passed = subject.frame_update_time-1
    subject.update time_passed
    subject.frame_time.should == time_passed
    subject.frame_num.should == 0

    time_passed_again = 2
    subject.update time_passed_again
    # we rolled over the time
    subject.frame_time.should == 1
    subject.frame_num.should == 1

    time_passed_again = subject.frame_update_time
    subject.update time_passed_again
    # we rolled over the time
    subject.frame_time.should == 1
    subject.frame_num.should == 0
  end

  it 'should stop animating' do
    subject.stop_animating
    subject.animating.should equal(false)
  end

  it 'should start animating' do
    subject.start_animating
    subject.animating.should equal(true)
  end

  it 'should set the action and animate accordingly for single frame' do
    subject.animating = true
    @resource_manager.expects(:load_animation_set).with(@actor, :foo).returns([image1])
    subject.action_changed :idle, :foo

    subject.animating.should be_false
    subject.frame_num.should == 0
  end

  it 'should set the action and animate accordingly for many frames' do
    subject.animating = false
    @resource_manager.expects(:load_animation_set).with(@actor, :foo).returns(images)
    subject.action_changed :idle, :foo

    subject.animating.should be_true
    subject.frame_num.should == 0
  end

end
