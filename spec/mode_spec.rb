require File.join(File.dirname(__FILE__),'helper')
require 'mode'

describe 'A new mode' do
  before do
    @config = {:screen_resolution => [800,600] }
    @mode = Mode.new :input_manager, :actor_factory, 
      :resource_manager, :sound_manager, @config, :levels
  end

  it 'should construct' do
    @mode.should_not be_nil
  end

  it 'should register drawables by parallax and layer'
  it 'should unregister drawables by parallax and layer'
  it 'should draw drawables by parallax and layers' do
    FakeDrawable = Struct.new :layer, :parallax

    a = FakeDrawable.new
    b = FakeDrawable.new
    c = FakeDrawable.new
    d = FakeDrawable.new
    e = FakeDrawable.new
    f = FakeDrawable.new
    x = FakeDrawable.new
    y = FakeDrawable.new
    z = FakeDrawable.new
    @mode.drawables = {
      2 => {3=> [a,b,c]},
      6 => {7=> [d,e,f]},
      9 => {13=> [x,y,z]},
    }
    @mode.move_layer(2, 3, 6, 7).should == [d,e,f]
    @mode.drawables[6][7].should_not be_nil
    @mode.drawables[6][7].should == [a,b,c]
    @mode.drawables[2][3].should be_nil
  end
  it 'should move drawables layers' do 
    FakeDrawable = Struct.new :layer, :parallax

    a = FakeDrawable.new
    b = FakeDrawable.new
    c = FakeDrawable.new
    d = FakeDrawable.new
    e = FakeDrawable.new
    f = FakeDrawable.new
    x = FakeDrawable.new
    y = FakeDrawable.new
    z = FakeDrawable.new
    @mode.drawables = {
      2 => {3=> [a,b,c]},
      6 => {7=> [d,e,f]},
      9 => {13=> [x,y,z]},
    }
    @mode.move_layer(2, 3, 6, 7).should == [d,e,f]
    @mode.drawables[6][7].should_not be_nil
    @mode.drawables[6][7].should == [a,b,c]
    @mode.drawables[2][3].should be_nil
  end
end
