require File.join(File.dirname(__FILE__),'helper')


describe 'A new stage' do
  FakeDrawable = Struct.new :layer, :parallax

  before do
    @config = {:screen_resolution => [800,600] }
    @actor_factory = stub(:director= => nil)
    @stage = Stage.new :input_manager, @actor_factory, 
      :resource_manager, :sound_manager, @config, :backstage, {}
  end

  it 'should construct' do
    @stage.should_not be_nil
  end

  it 'should have access to backstage' do
    @stage.backstage.should == :backstage
  end

  it 'should register drawables by parallax and layer'
  it 'should unregister drawables by parallax and layer'
  it 'should draw drawables by parallax and layers' do
    a = FakeDrawable.new
    b = FakeDrawable.new
    c = FakeDrawable.new
    d = FakeDrawable.new
    e = FakeDrawable.new
    f = FakeDrawable.new
    x = FakeDrawable.new
    y = FakeDrawable.new
    z = FakeDrawable.new
    @stage.drawables = {
      2 => {3=> [a,b,c]},
      6 => {7=> [d,e,f]},
      9 => {13=> [x,y,z]},
    }
    @stage.move_layer(2, 3, 6, 7).should == [d,e,f]
    @stage.drawables[6][7].should_not be_nil
    @stage.drawables[6][7].should == [a,b,c]
    @stage.drawables[2][3].should be_nil
  end
  it 'should move drawables layers' do 

    a = FakeDrawable.new
    b = FakeDrawable.new
    c = FakeDrawable.new
    d = FakeDrawable.new
    e = FakeDrawable.new
    f = FakeDrawable.new
    x = FakeDrawable.new
    y = FakeDrawable.new
    z = FakeDrawable.new
    @stage.drawables = {
      2 => {3=> [a,b,c]},
      6 => {7=> [d,e,f]},
      9 => {13=> [x,y,z]},
    }
    @stage.move_layer(2, 3, 6, 7).should == [d,e,f]
    @stage.drawables[6][7].should_not be_nil
    @stage.drawables[6][7].should == [a,b,c]
    @stage.drawables[2][3].should be_nil
  end

  describe "#modal_actor" do
    it 'pauses, shows actor, unpauses when that actor dies'
  end
end
