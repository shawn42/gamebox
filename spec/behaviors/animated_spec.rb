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

  let(:image0) { stub('image 1', width: 5, height: 6) }
  let(:image1) { stub('image 2', width: 7, height: 8) }
  let(:images) { [image0, image1] }

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

  it 'shouldnt update frame for non-animating' do
    subject
    actor.animating = false
    actor.image.should == image0
    director.fire :update, 61

    actor.image.should == image0
  end

  it 'should update frame for animating' do
    subject
    actor.image.should == image0

    director.fire :update, 61
    actor.image.should == image1

    director.fire :update, 60
    actor.image.should == image0

    director.fire :update, 30
    actor.image.should == image0
    director.fire :update, 30
    actor.image.should == image1

  end

  it 'should set the action and animate accordingly for single frame' do
    subject
    actor.animating = true
    @resource_manager.expects(:load_animation_set).with(actor, :foo).returns([image1])
    actor.action = :foo

    actor.animating.should be_false
  end

  it 'should set the action and animate accordingly for many frames' do
    subject
    actor.animating = false
    @resource_manager.expects(:load_animation_set).with(actor, :foo).returns(images)
    actor.action = :foo

    actor.animating.should be_true
  end

end
