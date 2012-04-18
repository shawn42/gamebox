require File.join(File.dirname(__FILE__),'helper')


describe Stage do
  inject_mocks :input_manager, :actor_factory, :resource_manager, 
    :sound_manager, :config_manager, :director, :this_object_context
  FakeDrawable = Struct.new :layer, :parallax

  before do
    @config_manager.stubs(:[]).with(:screen_resolution).returns([800,600])
    @actor_factory.stubs(:director=)
    subject.configure(:backstage, {})
  end

  it 'should construct' do
    subject.should_not be_nil
  end

  it 'should have access to backstage' do
    subject.backstage.should == :backstage
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
    subject.drawables = {
      2 => {3=> [a,b,c]},
      6 => {7=> [d,e,f]},
      9 => {13=> [x,y,z]},
    }
    subject.move_layer(2, 3, 6, 7).should == [d,e,f]
    subject.drawables[6][7].should_not be_nil
    subject.drawables[6][7].should == [a,b,c]
    subject.drawables[2][3].should be_nil
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
    subject.drawables = {
      2 => {3=> [a,b,c]},
      6 => {7=> [d,e,f]},
      9 => {13=> [x,y,z]},
    }
    subject.move_layer(2, 3, 6, 7).should == [d,e,f]
    subject.drawables[6][7].should_not be_nil
    subject.drawables[6][7].should == [a,b,c]
    subject.drawables[2][3].should be_nil
  end

  describe "#modal_actor" do
    it 'pauses, shows actor, unpauses when that actor dies; ug, how to test this?'
  end
end
