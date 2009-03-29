require 'behavior'
# keeps track of an image for you based on the actor's class, and
# current action, and frame num
# by default it expects images to be:
# data/graphics/classname/action/01..n.png
class Animated < Behavior
  FRAME_UPDATE_TIME = 60

  def setup
    @images = {}
    @frame_time = 0
    
    # all animated actors have to have an idle animation
    # data/graphics/ship/idle/1.png
    @frame_num = 0
    self.action = :idle

    animated_obj = self

    @actor.instance_eval do
      (class << self; self; end).class_eval do
        define_method :image do 
          animated_obj.image
        end
        define_method :start_animating do
          animated_obj.start_animating
        end
        define_method :stop_animating do
          animated_obj.stop_animating
        end
        define_method :action= do |action_sym|
          animated_obj.action = action_sym
        end
        define_method :animated do 
          animated_obj
        end
      end
    end

  end

  def update(time)
    return unless @animating
    if @frame_time > FRAME_UPDATE_TIME
      next_frame
      @frame_time = 0
    else
      @frame_time += time
    end
  end

  def next_frame()
    @frame_num = (@frame_num + 1) % @images[@action].size
  end

  # load all the images for this action
  def load_action(action)
    @actor.resource_manager.load_animation_set @actor, action 
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
