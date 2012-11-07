# in charge of registering / showing / hiding of actor views
define_behavior :visible do
  requires :renderer
  setup do
    actor.has_attribute :visible
  end

  react_to do |message, *args|
    if message == :show
      renderer.register_drawable opts[:view] unless actor.visible
    elsif message == :hide
      renderer.unregister_drawable opts[:view] if actor.visible
    end
    actor.visible = message == :show
  end
end
