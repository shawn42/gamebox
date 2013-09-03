require 'helper'

describe :label do

  subjectify_actor(:label)

  it 'has the label behavior' do
    behaviors = subject.instance_variable_get('@behaviors')
    behaviors.should include(:label)
  end

  describe "#behavior" do
    subjectify_behavior(:label)

    let(:stylish_font) { stub(calc_width: 22, height: 30) }

    before do
      @actor.stubs(has_attributes: nil, font_name: "fonty.ttf", text: "some text",
                   font_size: 22, color: :red, :width= => nil, :height= => nil)
      @font_style_factory.stubs(:build)
      @actor.stubs(:font_style).returns(stylish_font)
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
      @font_style_factory.stubs(:build).with('fonty.ttf', 22, :red).returns(stylish_font)
      @actor.expects(:has_attributes).with(font_style: stylish_font)

      stylish_font.stubs(:calc_width).with("some text").returns(:some_stylish_width)
      stylish_font.stubs(:height).returns(:some_stylish_height)

      @actor.expects(:width=).with(:some_stylish_width)
      @actor.expects(:height=).with(:some_stylish_height)
     
      subject
    end

    it 'listens for text changes' do
      subject
      @actor.stubs(text: "foo")

      font_style = stub(height: 13)
      font_style.stubs(:calc_width).with("foo").returns(73)
      @actor.stubs(font_style: font_style)

      @actor.expects(:width=).with(73)
      @actor.expects(:height=).with(13)

      @actor.fire :text_changed
    end

    it 'listens for font color changes' do
      subject
      font_style = stub
      font_style.expects(:color=).with(:red)
      @actor.stubs(font_style: font_style, color: :red)

      @actor.fire :color_changed
    end

    it 'listens for font name changes' do
      subject
      @actor.stubs(text: "foo", font_name: "asimov.ttf")

      font_style = stub(height: 13)
      font_style.stubs(:calc_width).with("foo").returns(73)

      font_style.expects(:name=).with("asimov.ttf")
      font_style.expects(:reload)
      @actor.expects(:width=).with(73)
      @actor.expects(:height=).with(13)

      @actor.stubs(font_style: font_style)

      @actor.fire :font_name_changed
    end

    it 'listens for font size changes' do
      subject
      @actor.stubs(text: "foo", font_size: 14)

      font_style = stub(height: 13)
      font_style.stubs(:calc_width).with("foo").returns(73)

      font_style.expects(:size=).with(14)
      font_style.expects(:reload)
      @actor.expects(:width=).with(73)
      @actor.expects(:height=).with(13)

      @actor.stubs(font_style: font_style)

      @actor.fire :font_size_changed
    end

  end
end

