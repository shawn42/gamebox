require 'helper'
require 'background'

describe 'a new Background' do
  before do 
    opts = {:level=>"level", :input=>"input", :resources=>"resource"}
    @test_me = Background.new opts
  end

  it 'should do something'
end
