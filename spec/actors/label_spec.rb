require 'helper'

describe :label do

  subjectify_actor(:label)

  it 'has the label behavior' do
    behaviors = subject.instance_variable_get('@behaviors')
    behaviors.should include(:label)
  end

  describe "#behavior" do
    subjectify_behavior(:label)

    before do
      @actor.stubs(has_attributes: nil, font_name: "fonty.ttf",
                   font_size: 22, color: :red)
      @font_style_factory.stubs(:build)
    end

    it 'sets up attributes on actor' do
      @actor.expects(:has_attributes).with(
        text: "",
        font_size: 30,
        font_name: "Asimov.ttf",
        color:     [250,250,250,255],
        width:     0,
        height:    0,
        layer:     1)
      @font_style_factory.stubs(:build).with('fonty.ttf', 22, :red).returns(:stylish_font)
      @actor.expects(:has_attributes).with(font_style: :stylish_font)
     
      subject.setup
    end

    it 'listens for text changes'
    it 'listens for font size changes'
    it 'listens for font name changes'
    it 'listens for font color changes'
  end
end

