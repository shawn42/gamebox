require 'helper'
require 'box'

describe 'a new Box' do
  before do 
    opts = {:level=>"level", :input=>"input", :resources=>"resource"}
    @test_me = Box.new opts
  end

  it 'should do something'
end
