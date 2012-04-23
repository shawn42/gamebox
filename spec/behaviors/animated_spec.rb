require 'helper'

describe :animated do
  it 'needs updated tests'

  let(:opts) { {} }
  subject { subcontext[:behavior_factory].add_behavior actor, :animated, opts }
  let(:director) { evented_stub(stub_everything('director')) }
  let!(:subcontext) do 
    it = nil
    Conject.default_object_context.in_subcontext{|ctx|it = ctx}; 
    _mocks = create_mocks *(Actor.object_definition.component_names + ActorView.object_definition.component_names - [:actor, :behavior, :this_object_context])
    _mocks.each do |k,v|
      it[k] = v
      it[:director] = director
    end
    it
  end
  let!(:actor) { subcontext[:actor] }

  let(:image1) { stub('image 1', width: 5, height: 6) }
  let(:image2) { stub('image 2', width: 7, height: 8) }
  let(:images) { [image1, image2] }

  before do
    @resource_manager.stubs(:load_animation_set).returns(images)
  end

  it 'should define attributes on @actor' do
    subject
    actor.should respond_to(:image)
    actor.should respond_to(:action)
    actor.should respond_to(:width)
    actor.should respond_to(:height)
    actor.should respond_to(:image=)
    actor.should respond_to(:action=)
    actor.should respond_to(:width=)
    actor.should respond_to(:height=)
  end

  # it 'shouldnt update frame for non-animating' do
  #   subject.stop_animating

  #   subject.update subject.frame_update_time+1

  #   subject.frame_time.should equal(0)
  #   subject.frame_num.should equal(0)
  # end

  # it 'should update frame for animating' do
  #   time_passed = subject.frame_update_time-1
  #   subject.update time_passed
  #   subject.frame_time.should == time_passed
  #   subject.frame_num.should == 0

  #   time_passed_again = 2
  #   subject.update time_passed_again
  #   # we rolled over the time
  #   subject.frame_time.should == 1
  #   subject.frame_num.should == 1

  #   time_passed_again = subject.frame_update_time
  #   subject.update time_passed_again
  #   # we rolled over the time
  #   subject.frame_time.should == 1
  #   subject.frame_num.should == 0
  # end

  # it 'should stop animating' do
  #   subject.stop_animating
  #   subject.animating.should equal(false)
  # end

  # it 'should start animating' do
  #   subject.start_animating
  #   subject.animating.should equal(true)
  # end

  # it 'should set the action and animate accordingly for single frame' do
  #   subject.animating = true
  #   @resource_manager.expects(:load_animation_set).with(@actor, :foo).returns([image1])
  #   subject.action_changed :idle, :foo

  #   subject.animating.should be_false
  #   subject.frame_num.should == 0
  # end

  # it 'should set the action and animate accordingly for many frames' do
  #   subject.animating = false
  #   @resource_manager.expects(:load_animation_set).with(@actor, :foo).returns(images)
  #   subject.action_changed :idle, :foo

  #   subject.animating.should be_true
  #   subject.frame_num.should == 0
  # end

end
