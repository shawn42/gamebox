require File.join(File.dirname(__FILE__),'helper')
require 'actor_view'

describe 'A new actor view' do

  it 'should be layered 0/1 by default' do
    @test_me = ActorView.new :stage, Actor.new({}), :wrapped_screen
    @test_me.layer.should == 0
    @test_me.parallax.should == 1
  end

  it 'should call setup on creation; tests that require subclassing seem wrong...'
  it 'should accept layered behavior params from actor'
  it 'should register for show/hide/remove events'
  it 'should manage a cached surface for drawing'
end
