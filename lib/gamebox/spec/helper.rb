# Helper methods and classes for writing specs for your gamebox application
def log(*args)
  # nothing for specs!
end
include Gamebox

module GameboxSpecHelpers
  module ClassMethods
    def inject_mocks(*mock_names_array)
      before { @_mocks_created = create_mocks(*mock_names_array) }
      subject { described_class.new @_mocks_created }
    end
  end

  module InstanceMethods

    def create_actor(type=:actor, args={})
      act = create_conjected_object type, nil, false
      act.configure args.merge(actor_type: type)
      act
    end

    def create_conjected_object(type, args={}, configure=true)
      actor_klass = ClassFinder.find(type)
      raise "Could not find actor class #{type}" unless actor_klass

      mocks = create_mocks *actor_klass.object_definition.component_names
      actor_klass.new(mocks).tap do |actor|
        actor.configure args if configure
      end
    end

    def create_actor_view(type=:actor_view, args={}, configure=true)
      create_conjected_object type, args, configure
    end

    def create_mocks(*args)
      {}.tap do |mocks|
        args.each do |mock_name|
          the_mock = mock(mock_name.to_s)
          instance_variable_set "@#{mock_name}", the_mock
          mocks[mock_name.to_sym] = the_mock
        end
      end
    end

    def create_stub_everythings(*args)
      {}.tap do |stubs|
        args.each do |stub_name|
          the_stub = stub_everything(stub_name.to_s)
          instance_variable_set "@#{stub_name}", the_stub
          stubs[stub_name.to_sym] = the_stub
        end
      end
    end

    def expects_event(target, event_name, expected_args)
      args = []
      target.when event_name do |*event_args|
        args << event_args
      end
      yield
      args.should == expected_args
    end

    def evented_stub(wrapped_object)
      EventedStub.new wrapped_object
    end
  end

  def self.included(base)
    base.send :include, InstanceMethods
    base.send :extend, ClassMethods
  end
end

class EventedStub
  extend Publisher
  can_fire_anything
  def initialize(object)
    @inner_stub = object
  end
  def method_missing(name, *args)
    @inner_stub.send name, *args
  end
  def fire(*args)
    super
  end
end

RSpec.configure do |configuration|
  configuration.include GameboxSpecHelpers
end
