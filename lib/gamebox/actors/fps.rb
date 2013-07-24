define_behavior :fps_label_updater do
  requires :director, :stage
  setup do
    @label = stage.create_actor :label, actor.attributes
    director.when :update do |time|
      @label.text = Gosu.fps
    end
  end

  remove do
    @label.remove
  end
end

define_actor :fps do
  has_behavior :fps_label_updater
end
