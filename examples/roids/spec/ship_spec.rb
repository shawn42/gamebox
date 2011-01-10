require 'spec_helper'

describe "Ship" do

  before do
    @stage = mock
    @stage.expects(:sound_manager)
    @stage.expects(:respond_to?).with(:register_physical_object).returns(true)
    @stage.expects(:register_physical_object).with(any_args)

    @ship = create_actor :ship, {:stage => @stage}
  end

  it "should be instantiatable" do
    @ship.should_not be_nil
  end

  it "should be animated" do
    @ship.is?(:animated).should be_true
  end

  it "should be physical" do
    @ship.is?(:physical).should be_true
  end

  it "should be audible" do
    @ship.is?(:audible).should be_true
  end

  it "should be updatable" do
    @ship.is?(:updatable).should be_true
    @ship.respond_to?(:update).should be_true
  end

  describe "KeyBindings" do

    it "should hook space to shoot" do
      @ship.expects(:shoot)
      @input_manager._handle_event(KeyPressed.new(:space))
    end

    it "should hook space to shoot" do
      @ship.expects(:shoot)
      @input_manager._handle_event(KeyPressed.new(:space))
    end

    it "should hook up to thrust" do
      @input_manager._handle_event(KeyPressed.new(:up))
      @ship.moving_forward?.should be_true
      @ship.action.should == :thrust
    end

  end

  describe "Update" do

    it "should have an invincible timer"

    it "should move on keybindings"

    it "should be able to shoot"

  end

end
