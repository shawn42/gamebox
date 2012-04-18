require File.join(File.dirname(__FILE__),'helper')
describe Actor do

  subject { create_actor :actor }

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

  describe "#has_attribute" do
    it 'adds an evented attribute'
  end

  describe "#has_attribute?" do
    it 'returns true if the actor has the attribute'
    it 'returns false if the actor does not have the attribute'
  end

  describe "#has_behavior?" do
    it 'returns true if the actor has the behavior'
    it 'returns false if the actor does not have the behavior'
  end

  describe ".define" do
    it 'adds an actor definition'  do
      Actor.define :mc_bane do |act|
        act.has_behavior  shooty: { bullets: 50 }
        act.has_behavior :death_on_d
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
