require 'behavior'
require 'inflector'
# keeps track of an image for you based on the actor's class, and
# current action, and frame num
# by default it expects images to be:
# data/graphics/classname/action/01..n.png
class Animated < Behavior
  FRAME_UPDATE_TIME = 60

  attr_accessor :action

  def setup
    @images = {}
    @frame_time = 0
    
    # all animated actors have to have an idle animation
    # data/graphics/ship/idle/1.png
    @action = :idle
    @frame_num = 1

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
    # TODO rewrite
    @frame_num = (@frame_num + 1) % @animation_length
#    @image = self.class.instance_variable_get("@images")[animation_image_set][@frame_num]
  end

  # load all the images for this action
  def load_action
    # TODO should resource_manager search the dir?
    # use pngs only for now
    actor_dir = Inflector.underscore(@actor.class)
    gfx_path = DATA_PATH+"graphics/"
    frames = Dir.glob("#{gfx_path}#{actor_dir}/#{@action}/*.png")
    action_imgs = []
    for frame in frames
      rel_path = frame.slice(gfx_path.size,frame.size)
      action_imgs << @actor.resource_manager.load_image(rel_path)
    end

    action_imgs
  end

  # returns the current image, or nil if no action is defined
  def image
    @images[@action] ||= load_action

    @images[@action].first
  end

  def start_animating
    @animating = true
  end

  def stop_animating
    @animating = false
  end
end
