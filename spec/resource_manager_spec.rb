require File.join(File.dirname(__FILE__),'helper')

describe 'A new resource manager' do
  let(:actor) { stub 'actor', actor_type: 'string' }
  subject { ResourceManager.new :wrapped_screen => stub(:screen => :fake_gosu) }

  it 'should load an actor image' do
    subject.expects(:load_image).with("string.png").returns(:surf)
    subject.load_actor_image(actor).should == :surf
  end

end
