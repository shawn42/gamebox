require File.join(File.dirname(__FILE__),'helper')
describe Actor do

  before do
    subject.configure actor_type: :actor
  end

  it 'should be alive' do
    subject.alive.should be_true
  end

  it 'should be the correct type' do
    subject.actor_type.should == :actor
  end

  it 'should fire anything' do
    Proc.new {
      subject.when :foofoo_bar do
        "blah"
      end
    }.should_not raise_error
  end

  # it 'should inherit parents behaviors' do
  #   @shawn = create_actor :shawn
  #   @shawn.is?(:smart).should be_true
  # end

  # it 'should be able to override parents behaviors' do
  #   @james = create_actor :james_kilton
  #   @james.is?(:smart).should be_true
  #   @james.instance_variable_get('@behaviors')[:smart].instance_variable_get('@opts').should == {:really=>true}
  # end

  describe "#add_behavior" do
    it 'can add a behavior to the actors list of behaviors'
  end

  describe ".define" do
    it 'adds an actor definition'  do
      Actor.define :mc_bane do
        has_behavior  shooty: { bullets: 50 }
        has_behavior :death_on_d
      end

      definition = Actor.definitions[:mc_bane]
      definition.should be
      definition.behaviors.should == [{shooty: {bullets:50}}, :death_on_d]
    end
  end

end
# 
# class Cool < Behavior; end
# class Smart < Behavior; end
# class Coder < Actor
#   has_behavior :smart, :cool
# end
# class Shawn < Coder; end
# class JamesKilton < Coder
#   has_behavior :smart => {:really => true}
# end
