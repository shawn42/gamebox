require 'helper'

describe FontStyle do
  let(:resource_manager) { mock }
  let(:font) { mock }
  
  subject do
    FontStyle.new resource_manager, "FooFace", 24, :aquamarine
  end

  before do
    resource_manager.expects(:load_font).with("FooFace", 24).returns font
  end
  
  it 'constructs a font from style specifications' do
    subject.name.should == "FooFace"
    subject.size.should == 24
    subject.color.should == :aquamarine
    subject.x_scale.should == 1
    subject.y_scale.should == 1
  end
  
  it 'calculates the width of the given text' do
    font.expects(:text_width).with("Blah").returns 56
    
    subject.calc_width("Blah").should == 56
  end
  
  it 'has a height' do
    font.expects(:height).returns 42
    subject.height.should == 42
  end
  
  it 'updates the font when the face or size change' do
    subject.name = "Bob"
    subject.size = 21
    resource_manager.expects(:load_font).with("Bob", 21).returns :newfont
    
    subject.reload
    subject.font.should == :newfont
  end
end


