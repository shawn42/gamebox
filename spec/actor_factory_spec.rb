require File.join(File.dirname(__FILE__),'helper')
describe ActorFactory do
  inject_mocks :input_manager, :wrapped_screen, :this_object_context, :resource_manager, :behavior_factory

  before do
    @opts = {:foo => :bar}
    @merged_opts = @opts.merge(actor_type: :some_actor)
  end
  
  describe "#build" do
    # Actor.definitions.clear
    # ActorView.definitions.clear
    Actor.define :some_actor
    ActorView.define :some_actor_view

    let(:actor) { create_actor }
    let(:actor_view) { create_actor_view :actor_view, {}, false }

    before do
      @actor = actor
      @subcontext = stub('subcontext')
      @subcontext.stubs(:[]).with(:actor).returns(actor)
      @subcontext.stubs(:[]).with("actor_view").returns(actor_view)
      @this_object_context.stubs(:in_subcontext).yields(@subcontext)
    end

    it 'configures the actor correctly' do
      subject.build(:some_actor, @opts).should == actor
      actor.opts.should == @merged_opts
    end

    it 'creates the associated view class' do
      subject.build(:some_actor, @opts).should == actor
      actor_view.actor.should == actor
    end
    
    it "raises on actor not found" do
      lambda{ subject.build :no_actor, @opts }.should raise_error(/no_actor not found/)
    end
    
  end
end
