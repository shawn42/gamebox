require 'helper'

describe Stage do
  inject_mocks :input_manager, :actor_factory, :resource_manager, 
    :sound_manager, :config_manager, :director, :this_object_context,
    :timer_manager, :viewport

  before do
    @renderer = stub('renderer', :clear_drawables)
    subject.stubs(:renderer).returns @renderer

    @viewport.stubs(:reset)
    subject.configure(:backstage, {})
  end

  describe "#configure" do

    it 'assigns backstage' do
      subject.backstage.should == :backstage
    end
  end

  describe "#create_actor" do
    it 'uses the actor factory to create an actor' do
      @actor_factory.stubs(:build).with(:foo, :bar).returns(:my_new_actor)
      subject.create_actor(:foo, :bar).should == :my_new_actor
    end
  end

  describe "#spawn" do
    it 'uses the actor factory to create an actor' do
      @actor_factory.stubs(:build).with(:foo, :bar).returns(:my_new_actor)
      subject.spawn(:foo, :bar).should == :my_new_actor
    end
  end

  describe "#create_actors_from_svg" do
    it 'maybe sticks around?'
  end

  describe "#draw" do
    it 'passes through to the renderer' do
      @renderer.expects(:draw).with(:target)
      subject.draw(:target)
    end
  end

  describe "#update" do
    it 'distributes the update' do
      @director.expects(:update).with(:time)
      @viewport.expects(:update).with(:time)
      @timer_manager.expects(:update).with(:time)
      subject.update(:time)
    end

    it 'checks for collisions'
  end


end
