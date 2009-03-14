require 'publisher'
class InputManager
  extend Publisher
  can_fire :key_up, :event_received

  attr_accessor :hooks
  
  def initialize
    @queue = EventQueue.new
    @queue.ignore = [
      ActiveEvent,
      JoyAxisEvent,
      JoyBallEvent,
      JoyDownEvent,
      JoyHatEvent,
      JoyUpEvent,
      ResizeEvent
    ]
    
    @clock = Clock.new do |c|
      c.target_framerate = 40
    end

    @hooks = {}
  end

  def main_loop(game)
    catch(:rubygame_quit) do
      loop do
        # add magic hooks
        @queue.each do |event|
          case event
          when KeyDownEvent
            case event.key
            when K_F
              puts "Framerate:#{@clock.framerate}"
            when K_ESCAPE
              throw :rubygame_quit
            end
          when QuitEvent
            throw :rubygame_quit
          end
          fire :event_received, event

          event_hooks = @hooks[event.class] 
          event_action_hooks = event_hooks[event.key] if event_hooks
          if event_action_hooks
            for callback in event_action_hooks
              callback.call
            end
          end
        end

        game.update @clock.tick
      end
    end
  end

#  def register_hooks(new_hooks)
#    for hook_def in new_hooks
#      register_hook hook_def
#    end
#  end
#  def register_hook(hook_def)
#    for event_type, val in hook_def
#      @hooks[event_type] ||= {}
#      for identifier, callback in val
#        @hooks[event_type][identifier] ||= []
#        @hooks[event_type][identifier] << callback
#      end
#    end
#  end
  def register_hook(event_class, *event_ids, &block)
    return unless block_given?
    @hooks[event_class] ||= {}
    for event_id in event_ids
      @hooks[event_class][event_id] ||= []
      @hooks[event_class][event_id] << block
    end
  end
  alias reg register_hook
end
