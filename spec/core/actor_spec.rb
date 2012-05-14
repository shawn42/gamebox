require 'helper'
describe Actor do

  subject { create_actor :actor }
  let(:behavior) { stub(react_to: nil) }

  it 'is alive' do
    subject.alive.should be_true
    subject.alive?.should be_true
  end

  it 'has the correct type' do
    subject.actor_type.should == :actor
  end

  it 'fires anything' do
    Proc.new {
      subject.when :foofoo_bar do
        "blah"
      end
    }.should_not raise_error
  end

  describe "#add_behavior" do
    it 'adds a behavior to the actors list of behaviors' do
      subject.add_behavior :foo, :bar
      subject.has_behavior?(:foo).should be_true
    end
  end

  describe "#remove_behavior" do
    it 'removes a behavior to the actors list of behaviors' do
      subject.add_behavior :foo, behavior
      subject.has_behavior?(:foo).should be_true

      subject.remove_behavior :foo
      subject.has_behavior?(:foo).should be_false
    end

    it 'doesnt raise if behavior already exists' do
      subject.remove_behavior :foo
      subject.has_behavior?(:foo).should be_false
    end
  end

  describe "#has_attribute" do
    it 'adds an evented attribute' do
      subject.has_attribute :foo, :default_value
      subject.foo.should == :default_value
    end

    it 'ignores default value if the attribute already exists' do
      subject.has_attribute :foo, :first_value
      subject.has_attribute :foo, :second_value
      subject.foo.should == :first_value
    end

    it 'adds attr w/o default' do
      subject.has_attribute :foo
      subject.foo.should be_nil
      subject.foo?.should be_false
    end
  end

  describe "#has_attribute?" do
    it 'returns true if the actor has the attribute' do
      subject.has_attribute :foo
      subject.has_attribute?(:foo).should be_true
    end

    it 'returns false if the actor does not have the attribute'
  end

  describe "#has_behavior?" do
    it 'returns true if the actor has the behavior'
    it 'returns false if the actor does not have the behavior'
  end

  describe "#emit" do
    it 'allows firing of events w/ the actor as the source'
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
