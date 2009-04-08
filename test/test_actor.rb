require 'helper'
require 'actor'

describe 'A new actor' do
  before do
    opts = {:level=>"level", :input=>"input", :resources=>"resource"}
    @actor = Actor.new opts
  end

  it 'should be alive' do
    @actor.alive?.should.equal true
  end

  it 'should be at (0,0)' do
    @actor.x.should.equal 0
    @actor.y.should.equal 0
  end

  it 'should have atts set' do
    @actor.level.should.equal "level" 
    @actor.input_manager.should.equal "input" 
    @actor.resource_manager.should.equal "resource" 
    @actor.behaviors.size.should.equal 0
  end

  it 'should fire anything' do
    should.not.raise do
      @actor.when :foofoo_bar do
        "blah"
      end
    end
  end

  it 'should setup behaviors' do
    should.flunk 'cannot test easily!'
  end

end
