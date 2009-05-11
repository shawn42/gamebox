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
      if c.respond_to? :calibrate
        c.calibrate 
        c.granularity = 2 if c.granularity < 2
      end
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

  def register_hook(event_class, *event_ids, &block)
    return unless block_given?
    @hooks[event_class] ||= {}
    for event_id in event_ids
      @hooks[event_class][event_id] ||= []
      @hooks[event_class][event_id] << block
    end
    listener = eval("self", block.binding) 
    listener.when :remove_me do
      unregister_hook event_class, *event_ids, &block
    end
  end
  alias reg register_hook

  def unregister_hook(event_class, *event_ids, &block)
    @hooks[event_class] ||= {}
    for event_id in event_ids
      @hooks[event_class][event_id] ||= []
      if block_given?
        @hooks[event_class][event_id].delete block
      else
#        for blocks in @hooks[event_class][event_id]
#          listener = eval("self", block.binding) 
#          @hooks[event_class][event_id].delete block if listener == id
#        end
      end
    end
  end
  alias unreg unregister_hook

  def clear_hooks
    @hooks = {}
  end
end
