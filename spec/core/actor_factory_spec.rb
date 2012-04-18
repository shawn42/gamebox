require 'helper'
describe ActorFactory do
  inject_mocks :input_manager, :wrapped_screen, :this_object_context, 
    :resource_manager, :behavior_factory, :actor_view_factory

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
      @this_object_context.stubs(:in_subcontext).yields(@subcontext)
      @actor_view_factory.stubs(:build)
    end

    it 'configures the actor correctly' do
      subject.build(:some_actor, @opts).should == actor
      actor.opts.should == @merged_opts
    end

    it 'creates the associated view class' do
      @actor_view_factory.expects(:build).with(actor, @opts)
      subject.build(:some_actor, @opts).should == actor
    end
    
    it "raises on actor not found" do
      lambda{ subject.build :no_actor, @opts }.should raise_error(/no_actor not found/)
    end
    
  end
end
