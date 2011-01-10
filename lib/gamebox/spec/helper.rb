# Helper methods and classes for writing specs for your gamebox application
module GameboxSpecHelpers

  def create_actor(type, args = {})
    InputManager.stub :setup
    basic_opts = {
      :stage => @stage = stub.as_null_object,
      :input => @input_manager = InputManager.new(:config_manager => "config_manager"),
      :sound => @sound_manager = stub.as_null_object,
      :director => @director = stub.as_null_object,
      :resources => @resource_manager = stub.as_null_object
    }.merge(args)

    klass = ClassFinder.find(type)

    raise "Could not find actor class #{type}" unless klass
    
    klass.new(basic_opts)
  end

end

RSpec.configure do |configuration|
  configuration.include GameboxSpecHelpers
end