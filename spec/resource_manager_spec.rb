require File.join(File.dirname(__FILE__),'helper')
require 'resource_manager'

describe 'A new resource manager' do
  before do
    @res_man = ResourceManager.new
  end

  it 'should load an actor image' do
    @res_man.should_receive(:load_image).with("string.png").and_return(:surf)
    @res_man.load_actor_image("FoopyPants").should == :surf
  end

end
