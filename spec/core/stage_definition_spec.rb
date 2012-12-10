require 'helper'

describe StageDefinition do
  let(:some_block) { Proc.new {} }

  describe "#requires" do
    it 'assigns the required injections' do
      subject.requires(:a, :b)
      subject.required_injections.should == [:a, :b]
    end
  end

  describe "#curtain_up" do
    it 'stores the block' do
      subject.curtain_up &some_block
      subject.curtain_up_block.should == some_block
    end
  end

  describe "#curtain_down" do
    it 'stores the block' do
      subject.curtain_down &some_block
      subject.curtain_down_block.should == some_block
    end
  end

  describe "#render_with" do
    it 'stores the renderer name' do
      subject.render_with :foopy
      subject.renderer.should == :foopy
    end
  end

  describe "#helpers" do
    it 'stores the block' do
      subject.helpers &some_block
      subject.helpers_block.should == some_block
    end
  end

end
