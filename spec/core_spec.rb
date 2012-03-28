require 'helper'

describe Gamebox do
  describe '.configure' do
    it 'yields the configuration object to the given block'
    it 'raises if no block is given'
  end

  describe '.configuration' do
    it 'returns a new configuration object on first call'
    it 'returns the same configuration object on subsequent calls'
  end
end
