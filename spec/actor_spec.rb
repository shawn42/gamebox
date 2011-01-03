require File.join(File.dirname(__FILE__),'helper')
describe 'A new actor' do
  before do
    opts = {:stage=>"stage", :input=>"input", 
      :resources=>"resource", :actor_type => :actor}
    @actor = Actor.new opts
  end

  it 'should be alive' do
    @actor.alive?.should be_true
  end

  it 'should be the correct type' do
    @actor.actor_type.should == :actor
  end

  it 'should be at (0,0)' do
    @actor.x.should equal(0)
    @actor.y.should equal(0)
  end

  it 'should have access to backstage' do
    @actor.stage = mock(:backstage => :stuff)
    @actor.backstage.should == :stuff
  end

  it 'should have atts set' do
    @actor.stage.should == "stage" 
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

  it 'should inherit parents behaviors' do
    @shawn = Shawn.new {}
    @shawn.is?(:smart).should be_true
  end

  it 'should be able to override parents behaviors' do
    @james = JamesKilton.new {}
    @james.is?(:smart).should be_true
    @james.instance_variable_get('@behaviors')[:smart].instance_variable_get('@opts').should == {:really=>true}
  end
end

class Cool < Behavior; end
class Smart < Behavior; end
class Coder < Actor
  has_behavior :smart, :cool
end
class Shawn < Coder; end
class JamesKilton < Coder
  has_behavior :smart => {:really => true}
end
