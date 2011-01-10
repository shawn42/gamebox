require File.join(File.dirname(__FILE__),'helper')

describe 'A new resource manager' do
  before do
    @res_man = ResourceManager.new :wrapped_screen => stub(:screen => :fake_gosu)
  end

  it 'should load an actor image' do
    @res_man.expects(:load_image).with("string.png").returns(:surf)
    @res_man.load_actor_image("FoopyPants").should == :surf
  end

end
