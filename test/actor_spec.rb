require File.join(File.dirname(__FILE__),'helper')
require 'actor'

describe 'A new actor' do
  before do
    opts = {:level=>"level", :input=>"input", :resources=>"resource"}
    @actor = Actor.new opts
  end

  it 'should be alive' do
    @actor.alive?.should be_true
  end

  it 'should be at (0,0)' do
    @actor.x.should equal(0)
    @actor.y.should equal(0)
  end

  it 'should have atts set' do
    @actor.level.should == "level" 
    @actor.input_manager.should == "input" 
    @actor.resource_manager.should == "resource" 
    @actor.behaviors.size.should equal(0)
  end

  it 'should fire anything' do
    Proc.new {
      @actor.when :foofoo_bar do
        "blah"
      end
    }.should_not raise_error
  end

  it 'should setup behaviors; hard to test'

end
