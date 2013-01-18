define_behavior :colored do
  requires :resource_manager

  setup do
    actor.has_attributes image: resource_manager.load_image(opts[:color])
  end
end
