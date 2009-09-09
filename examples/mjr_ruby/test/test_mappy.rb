require 'helper'
require 'mappy'

describe 'a new Mappy' do
  before do 
    opts = {:level=>"level", :input=>"input", :resources=>"resource"}
    @test_me = Mappy.new opts
  end

  it 'should do something'
end
