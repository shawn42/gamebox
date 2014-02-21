require 'helper'

describe 'A new resource manager' do
  subject { ResourceManager.new :wrapped_screen => stub(:screen => :fake_gosu) }

  context 'no image_name' do
    let(:actor) { stub 'actor', actor_type: 'string', do_or_do_not: nil }

    it 'should load an actor image' do
      subject.expects(:load_image).with("string.png").returns(:surf)
      subject.load_actor_image(actor).should == :surf
    end
  end

  context 'with image_name' do
    let(:actor) { 
      a = stub('actor')
      a.stubs(:do_or_do_not).with(:image_name).returns('string')
      a
    }

    it 'should load an actor image' do
      subject.expects(:load_image).with("string.png").returns(:surf)
      subject.load_actor_image(actor).should == :surf
    end
  end

end
