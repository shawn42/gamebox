# in charge of registering / showing / hiding of actor views
define_behavior :visible do
  requires :stage

  react_to do |message, *args|
    if message == :show
      stage.register_drawable opts[:view]
    elsif message == :hide
      stage.unregister_drawable opts[:view]
    end
  end
end
