require File.join(File.dirname(__FILE__),'helper')
require 'collidable'

describe 'A new collidable behavior' do
  before do
    @stage = mock(:register_collidable => nil)
    opts = {:actor_type => :actor, :stage=>@stage, :input=>"input", :resources=> :rm}
    @actor = Actor.new opts
    @collidable = Collidable.new @actor
  end

  it 'should define methods on actor' do
    @actor.respond_to?(:shape).should be_true
  end
end
