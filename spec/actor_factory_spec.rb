require File.join(File.dirname(__FILE__),'helper')
describe ActorFactory do
  inject_mocks :input_manager, :wrapped_screen, :this_object_context, :resource_manager, :behavior_factory

  before do
    @stage = mock('stage')
    @director = mock
    @opts = Actor::DEFAULT_PARAMS.merge({:foo => :bar})
    @merged_opts = @opts.merge(actor_type: :actor)
  end
  
  describe "#build" do
    let(:no_view_actor) { stub 'no view actor', configure: nil, show: nil, is?: false }
    let(:actor) { stub 'actor', configure: nil, show: nil, is?: false }
    let(:actor_view) { stub 'actor_view', configure: nil }
    before do
      @subcontext = stub('subcontext')
      @subcontext.stubs(:[]).with(:actor).returns(actor)
      @subcontext.stubs(:[]).with("actor_view").returns(actor_view)
      @subcontext.stubs(:[]).with(:no_view_actor).returns(no_view_actor)
      @subcontext.stubs(:[]).with(:no_actor).raises("cannot find")
      @this_object_context.stubs(:in_subcontext).yields(@subcontext)
    end

    it 'configures the actor correctly' do
      actor.expects(:configure).with(@merged_opts)
      subject.build(:actor, @stage, @opts).should == actor
    end

    it 'creates the associated view class' do
      actor_view.expects(:configure).with(actor)
      subject.build(:actor, @stage, @opts).should == actor
    end
    
    it "creates an Actor instance with no view" do
      @merged_opts[:actor_type] = :no_view_actor
      @subcontext.stubs(:[]).with("no_view_actor_view").raises("cannot find")
      subject.build(:no_view_actor, @stage, @opts).should == no_view_actor
    end
    
    it "raises on actor not found" do
      lambda{ subject.build :no_actor, @stage, @opts }.should raise_error(/no_actor not found/)
    end
    
  end
  
  class NoViewActor < Actor
  end
end
