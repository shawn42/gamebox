Behavior.define :fps_label_updater do
  requires :director
  setup do
    actor.has_attribute :text
    director.when :update do |time|
      actor.text = fps
    end
  end
end
Actor.define :fps do
  has_behavior :fps_label_updater
end
