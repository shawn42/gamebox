Behavior.define :fps_label_updater do
  requires :director, :stage
  setup do
    actor.has_attribute :label
    actor.label = stage.spawn :label, actor.attributes
    director.when :update do |time|
      label.text = fps
    end
  end
end
Actor.define :fps do
  has_behavior :fps_label_updater
end
