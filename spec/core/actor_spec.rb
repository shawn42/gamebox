require 'helper'
describe Actor do

  subject { create_actor :actor }
  let(:behavior) { stub(react_to: nil) }

  it 'is alive' do
    subject.should be_alive
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
    before do
      define_behavior :test_behavior do
        setup do
          actor.has_attributes(test_attr: opts[:test_attr])
        end
      end
    end

    it 'adds a behavior to the actor\'s list of behaviors' do
      pending "jacius doesn't understand conjected objects"
      subject.add_behavior :test_behavior
      subject.has_behavior?(:test_behavior).should be_true
    end

    it 'sets up the behavior on the actor' do
      pending "jacius doesn't understand conjected objects"
      subject.add_behavior :test_behavior
      subject.has_attribute?(:test_attr).should be_true
    end

    it 'configures the behavior with the given opts' do
      pending "jacius doesn't understand conjected objects"
      subject.add_behavior :test_behavior, test_attr: 'test'
      subject.test_attr.should == 'test'
    end

    it 'raises on nil behavior def' do
      lambda { subject.add_behavior nil }.should raise_exception(/nil behavior definition/)
    end

    it 'raises for missing behavior' do
      lambda { subject.add_behavior :undefined_behavior }.should raise_exception
    end

    it 'creates all required behaviors'
    it 'mixes in helpers'
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

    it 'returns false if the actor does not have the attribute' do
      subject.has_attribute?(:foo).should be_false
    end
  end

  describe "#has_behavior?" do
    it 'returns true if the actor has the behavior' do
      subject.add_behavior :jumper, behavior
      subject.has_behavior?(:jumper).should be_true
    end

    it 'returns false if the actor does not have the behavior' do
      subject.has_behavior?(:jumper).should be_false
    end
  end

  describe "#emit" do
    it 'allows firing of events w/ the actor as the source' do
      expects_event(subject, :foopy, [[87]]) do
        subject.emit :foopy, 87
      end
    end
  end

  describe "#react_to" do
    let(:foo) { mock }
    let(:bar) { mock }
    it 'sends the message to all its behaviors' do
      foo.expects(:react_to).with(:hello, :world)
      bar.expects(:react_to).with(:hello, :world)
      subject.add_behavior :foo, foo
      subject.add_behavior :bar, bar

      subject.react_to :hello, :world
    end
  end

  describe "#remove" do
    let(:foo) { mock }

    it 'kills the actor' do
      subject.remove
      subject.should_not be_alive
    end

    it 'sends :remove to behaviors' do
      foo.expects(:react_to).with(:remove)
      subject.add_behavior :foo, foo

      subject.remove
    end

    it 'fires :remove me' do
      foo.expects(:react_to).with(:remove)
      subject.add_behavior :foo, foo

      expects_event(subject, :remove_me) do
        subject.remove
      end
    end
  end


  describe ".define" do
    it 'adds an actor definition'  do
      Actor.define :mc_bane2 do |act|
        act.has_behavior  shooty: { bullets: 50 }
        act.has_behavior :death_on_d
      end

      definition = Actor.definitions[:mc_bane2]
      definition.should be
      definition.behaviors.should == [{shooty: {bullets:50}}, :death_on_d]
    end
  end


end
