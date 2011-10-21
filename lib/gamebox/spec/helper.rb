# Helper methods and classes for writing specs for your gamebox application
module GameboxSpecHelpers

  def create_actor(type, args = {})
    InputManager.any_instance.stubs :setup
    basic_opts = {
      stage: @stage = stub_everything,
      input: @input_manager = InputManager.new(wrapped_screen: 'wrapped_screen', config_manager: 'config_manager'),
      sound: @sound_manager = stub_everything,
      director: @director = stub_everything,
      resources: @resource_manager = stub_everything,
    }.merge(args)

    klass = ClassFinder.find(type)

    raise "Could not find actor class #{type}" unless klass
    
    klass.new(basic_opts)
  end

end

RSpec.configure do |configuration|
  configuration.include GameboxSpecHelpers
end
