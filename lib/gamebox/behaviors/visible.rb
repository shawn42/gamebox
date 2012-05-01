# in charge of registering / showing / hiding of actor views
define_behavior :visible do
  requires :stage
  setup do
    actor.has_attribute :visible
  end

  react_to do |message, *args|
    if message == :show
      stage.register_drawable opts[:view] unless actor.visible
    elsif message == :hide
      stage.unregister_drawable opts[:view] if actor.visible
    end
    actor.visible = message == :show
  end
end
