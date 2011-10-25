require 'helper'

describe Emitter do
  before do
    @stage = stub_everything
    # @stage.expects(:sound_manager)
    # @stage.expects(:respond_to?).with(:register_physical_object).returns(true)
    # @stage.expects(:register_physical_object).with(any_args)

    @emitter = create_actor :emitter, {:stage => @stage}
  end

  it 'should be' do
    @emitter.should be
  end

  it 'should add a timer for spawning particle actors' do
  end

end
