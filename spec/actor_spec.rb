require File.join(File.dirname(__FILE__),'helper')
describe Actor do
  inject_mocks :stage, :input_manager, :director, :resource_manager, :wrapped_screen,
    :backstage, :sound_manager

  before do
    subject.configure actor_type: :actor
  end

  it 'should be alive' do
    subject.alive?.should be_true
  end

  it 'should be the correct type' do
    subject.actor_type.should == :actor
  end

  it 'should be at (0,0)' do
    subject.x.should equal(0)
    subject.y.should equal(0)
  end

  it 'should have atts set' do
    subject.behaviors.size.should equal(0)
  end

  it 'should fire anything' do
    Proc.new {
      subject.when :foofoo_bar do
        "blah"
      end
    }.should_not raise_error
  end

  it 'should inherit parents behaviors' do
    @shawn = create_actor :shawn
    @shawn.is?(:smart).should be_true
  end

  it 'should be able to override parents behaviors' do
    @james = create_actor :james_kilton
    @james.is?(:smart).should be_true
    @james.instance_variable_get('@behaviors')[:smart].instance_variable_get('@opts').should == {:really=>true}
  end

  describe '#viewport' do
    it 'should return the stages viewport' do
      @stage.stubs(:viewport).returns(:da_viewport)
      subject.viewport.should == :da_viewport
    end
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
