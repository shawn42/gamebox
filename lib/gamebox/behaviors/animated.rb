
# keeps track of an image for you based on the actor's class, and
# current action, and frame num
# by default it expects images to be:
# data/graphics/actor_type/action/01..n.png
Behavior.define :animated do
  requires :resource_manager, :director

  setup do
    # METHOD DEFS; TODO how to clean this up?
    define_singleton_method :start_animating do
      actor.animating = true
    end

    define_singleton_method :stop_animating do
      actor.animating = false
    end

    define_singleton_method :next_frame do
      action_set = @images[actor.action]
      @frame_num = (@frame_num + 1) % action_set.size unless action_set.nil?
    end

    # load all the images for this action
    define_singleton_method :load_action do |action|
      resource_manager.load_animation_set actor, action
    end

    define_singleton_method :action_changed do |old_action, new_action|
      @images[new_action] ||= load_action(new_action)
      if @images[new_action].size > 1
        actor.react_to :start_animating
      else
        actor.react_to :stop_animating
      end
      @frame_num = 0
      set_image
    end

    define_singleton_method :set_image do
      action_set = @images[actor.action]
      raise "unknown action set #{actor.action} for #{actor}" if action_set.nil?

      image = action_set[@frame_num]
      actor.image = image
      actor.width = image.width
      actor.height = image.height
    end


    # REAL STUFF
    @images = {}
    @frame_update_time = @opts[:frame_update_time]
    @frame_update_time ||= 60
    # @action = @opts[:action] ||= :idle
    @frame_time = 0

    # all animated actors have to have an idle animation
    # data/graphics/ship/idle/1.png
    @frame_num = 0

    actor.has_attributes :animating, :action, :image, :width, :height

    actor.when :action_changed do |old_action, new_action|
      action_changed old_action, new_action
    end

    actor.action = :idle

    director.when :update do |time|
      if actor.animating
        @frame_time += time
        if @frame_time > @frame_update_time
          next_frame
          @frame_time = @frame_time-@frame_update_time
        end
        set_image
      end
    end
    reacts_with :start_animating, :stop_animating

    actor.react_to :start_animating
  end

end
