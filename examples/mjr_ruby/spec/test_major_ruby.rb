require 'helper'
require 'major_ruby'

describe 'a new MajorRuby' do
  before do 
    opts = {:level=>"level", :input=>"input", :resources=>"resource"}
    @test_me = MajorRuby.new opts
  end

  it 'should do something'
end
