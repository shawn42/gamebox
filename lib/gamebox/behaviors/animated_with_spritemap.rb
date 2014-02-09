define_behavior :animated_with_spritemap do
  requires :resource_manager, :director
  setup do

    actor.has_attributes animation_file: opts[:file],
                         action: :idle, 
                         animating: true,
                         image: nil,
                         width: 1,
                         height: 1

    setup_animation if actor.animation_file?

    actor.when :animation_file_changed do
      setup_animation
    end

  end

  remove do
    actor.input.unsubscribe_all self
    actor.unsubscribe_all self
  end
  
  helpers do
    def setup_animation
      @frame_update_time = opts[:interval] || 60
      @frame_time = 0

      @frame_num = 0

      file = actor.animation_file
      rows, cols, actions = opts[:rows], opts[:cols], opts[:actions]
      # @spritemap = resource_manager.load_image file
      
      # negatives means rows/cols instead of w/h 
      #   http://www.libgosu.org/rdoc/Gosu/Image.html#load_tiles-class_method
      @sprites = resource_manager.load_tiles file, -cols, -rows
      
      @frames = {}
      actions.each do |action, frames|
        frames = frames.to_a if frames.is_a?(Range)
        images = Array.wrap(frames).map { |f| @sprites[f] }
        @frames[action] = images
      end

      actor.when :action_changed do |old_action, new_action|
        unless old_action == new_action
          action_changed old_action, new_action
          actor.animating = @frames[new_action].size > 1
        end
      end
      
      action_changed nil, actor.action

      director.when :update do |time|
        if actor.animating
          @frame_time += time
          if @frame_time > @frame_update_time
            next_frame
            @frame_time = @frame_time-@frame_update_time
          end
          set_frame
        end
      end

    end

    def next_frame
      action_set = @frames[actor.action]
      return unless action_set
      @frame_num = @frame_num + 1
      if @frame_num >= action_set.size
        actor.emit :action_loop_complete
        @frame_num = 0
      end
      # @frame_num = (@frame_num + 1) % action_set.size unless action_set.nil?
    end

    def action_changed(old_action, new_action)
      @frame_num = 0
      set_frame
    end

    def set_frame
      action_set = @frames[actor.action]
      raise "unknown action set #{actor.action} for #{actor}" if action_set.nil?

      image = action_set[@frame_num]
      actor.image = image
      actor.width = image.width
      actor.height = image.height
    end

  end
  
end

