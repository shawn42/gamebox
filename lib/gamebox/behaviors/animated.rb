
# keeps track of an image for you based on the actor's class, and
# current action, and frame num
# by default it expects images to be:
# data/graphics/classname/action/01..n.png
class Animated < Behavior
  construct_with :actor, :resource_manager, :director

  attr_accessor :frame_time, :frame_num, :animating, :frame_update_time
  def setup
    @images = {}
    @frame_update_time = @opts[:frame_update_time]
    @frame_update_time ||= 60
    @frame_time = 0

    # all animated actors have to have an idle animation
    # data/graphics/ship/idle/1.png
    @frame_num = 0

    actor.has_attributes :action, :image, :width, :height
    actor.action = :idle
    actor.when :action_changed do |old_action, new_action|
      action_changed old_action, new_action
    end

    director.when :update do |time|
      update time
    end

    reacts_with :start_animating, :stop_animating

    start_animating
  end

  def update(time)
    return unless @animating
    @frame_time += time
    if @frame_time > @frame_update_time
      next_frame
      @frame_time = @frame_time-@frame_update_time
    end
    set_image
  end

  def next_frame()
    action_set = @images[actor.action]
    @frame_num = (@frame_num + 1) % action_set.size unless action_set.nil?
  end

  # load all the images for this action
  def load_action(action)
    resource_manager.load_animation_set actor, action 
  end

  def action_changed(old_action, new_action)
    @images[new_action] ||= load_action(new_action)
    if @images[new_action].size > 1
      start_animating
    else
      stop_animating
    end
    @frame_num = 0
    set_image
  end

  def set_image
    action_set = @images[actor.action]
    if action_set
      image = action_set[@frame_num]
      actor.image = image
      actor.width = image.width
      actor.height = image.height
    end
  end

  def start_animating
    @animating = true
  end

  def stop_animating
    @animating = false
  end

end
