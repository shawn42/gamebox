require 'behavior'
# keeps track of an image for you based on the actor's class, and
# current action, and frame num
# by default it expects images to be:
# data/graphics/classname/action/01..n.png
class Animated < Behavior
  requires_behavior :updatable
  
  attr_accessor :frame_time, :frame_num, :animating, :frame_update_time
  def setup
    @images = {}
    @frame_update_time = @opts[:frame_update_time]
    @frame_update_time ||= 60
    @frame_time = 0
    
    # all animated actors have to have an idle animation
    # data/graphics/ship/idle/1.png
    @frame_num = 0
    self.action = :idle

    relegates :image, :width, :height, 
      :start_animating, :stop_animating, :animated,
      :action, :action=

  end

  def animated
    self
  end

  def width
    image.size[0]
  end

  def height
    image.size[1]
  end

  def update(time)
    return unless @animating
    @frame_time += time
    if @frame_time > @frame_update_time
      next_frame
      @frame_time = @frame_time-@frame_update_time
    end
  end

  def next_frame()
    @frame_num = (@frame_num + 1) % @images[@action].size
  end

  # load all the images for this action
  def load_action(action)
    @actor.resource_manager.load_animation_set @actor, action 
  end

  def action
    @action
  end

  def action=(new_action)
    @images[new_action] ||= load_action(new_action)
    if @images[new_action].size > 1
      start_animating
    else
      stop_animating
    end
    @frame_num = 0
    @action = new_action
  end

  # returns the current image, or nil if no action is defined
  def image
    @images[@action][@frame_num]
  end

  def start_animating
    @animating = true
  end

  def stop_animating
    @animating = false
  end

end
