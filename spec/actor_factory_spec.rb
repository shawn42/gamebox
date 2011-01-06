require File.join(File.dirname(__FILE__),'helper')
describe ActorFactory do
  before do
    @input_manager = mock
    @screen = mock
    @stage = mock
    @resource_manager = mock
    @stage = mock
    @stage.stub(:resource_manager).and_return(@resource_manager)
    @director = mock
    params = {:input_manager => @input_manager, :wrapped_screen => @screen}
    @target = ActorFactory.new params
    @target.director = @director
    @opts = {:foo => :bar}
    @basic_opts = {
      :stage => @stage,
      :input => @input_manager,
      :director => @director,
      :resources => @resource_manager,
    }
    @merged_opts = @basic_opts.merge(@opts)
    
  end
  
  describe "#build" do
    it "creates an Actor instance and registers the view" do

      view_actor = nil
      @stage.should_receive(:register_drawable) do |view|
        view.class.should == ActorView
        view.stage.should == @stage
        view.wrapped_screen.should == @screen
        view.actor.class.should == Actor
        view_actor = view.actor
      end
      @merged_opts[:actor_type] = :actor
      
      act = @target.build :actor, @stage, @opts
      act.opts.should == @merged_opts
      act.class.should == Actor
      act.should == view_actor
    end
    
    it "creates an Actor instance with no view" do
      @merged_opts[:actor_type] = :no_view_actor
      
      act = @target.build :no_view_actor, @stage, @opts
      act.opts.should == @merged_opts
      act.class.should == NoViewActor
    end
    
    it "nil on actor not found" do
      lambda{ @target.build :no_actor, @stage, @opts }.should raise_error("no_actor not found")
    end
    
  end
  
  class NoViewActor < Actor
  end
end
