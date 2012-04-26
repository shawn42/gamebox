require 'helper'

describe FontStyleFactory do
  describe "#build" do
    inject_mocks :this_object_context
    let(:style) { stub }
    before do
      @this_object_context.stubs(:in_subcontext).yields(@this_object_context)
      @this_object_context.stubs(:[]).with('font_style').returns style
    end

    it 'pulls the font style from the context and configures it' do
      style.expects(:configure).with('arial', 22, :purple, 2, 0.5)
      subject.build 'arial', 22, :purple, 2, 0.5
    end
  end
end
