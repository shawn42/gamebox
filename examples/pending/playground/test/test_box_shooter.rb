require 'helper'
require 'box_shooter'

describe 'a new BoxShooter' do
  before do 
    opts = {:level=>"level", :input=>"input", :resources=>"resource"}
    @test_me = BoxShooter.new opts
  end

  it 'should do something'
end
