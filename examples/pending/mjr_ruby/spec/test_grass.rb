require 'helper'
require 'grass'

describe 'a new Grass' do
  before do 
    opts = {:level=>"level", :input=>"input", :resources=>"resource"}
    @test_me = Grass.new opts
  end

  it 'should do something'
end
