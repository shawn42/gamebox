Behavior.define :fps_label_updater do
  requires :director, :stage
  setup do
    @label = stage.create_actor :label, actor.attributes
    director.when :update do |time|
      @label.text = Gosu.fps
    end
  end
  react_to do |msg, *args|
    @label.remove if msg == :remove
  end
end
Actor.define :fps do
  has_behavior :fps_label_updater
end
