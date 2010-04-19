require File.join(File.dirname(__FILE__),'helper')
require 'stage_manager'

describe 'A new stage manager' do
  before do
#    opts = {:resource_manager => stub, :actor_factory => stub, :input_manager => stub, 
#      :sound_manager => stub, :config_manager => stub}
#    @stage_manager = StageManager.new opts
  end

  it 'should construct' #do
#    @stage_manager.should_not be_nil
#  end

  describe '#prev_stage' do
    it 'should exit on prev_stage of first stage'
    it 'should go to prev stage'
  end
  describe '#next_stage' do
    it 'should exit on next_stage of last stage'
    it 'should go to next stage'
  end
  describe '#restart_stage' do
    it 'should restart the current stage'
  end
end
