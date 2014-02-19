require 'helper'

describe 'a new Earth' do
  before do 
    opts = {:level=>"level", :input=>"input", :resources=>"resource"}
    @test_me = Earth.new opts
  end

  it 'should do something'
end
