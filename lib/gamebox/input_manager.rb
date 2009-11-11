require 'publisher'

# InputManager handles the pumping of SDL for events and distributing of said events.
# You can gain access to these events by registering for all events, 
# or just the ones you care about.
# All events:
# input_manager.when :event_received do |evt|
#   ...
# end
# 
# Some events:
# input_manager.reg KeyPressed, :space do
#   ...
# end
#
# Don't forget to unreg for these things between levels and stages, 
# since the InputManager is shared across levels and stages.
class InputManager
  extend Publisher
  can_fire :key_up, :event_received


  # lookup map for mouse button clicks
  MOUSE_BUTTON_LOOKUP = {
    MOUSE_LEFT   => :left,
    MOUSE_MIDDLE => :middle,
    MOUSE_RIGHT  => :right,
  }

  constructor :config_manager

  # Sets up the clock and main event loop. You should never call this method, 
  # as this class should be initialized by diy.
  def setup
    @queue = EventQueue.new
    @queue.enable_new_style_events
    @queue.ignore = [
      InputFocusGained,
      InputFocusLost,
      MouseFocusGained,
      MouseFocusLost,
      WindowMinimized,
      WindowUnminimized,
      JoystickAxisMoved,
      JoystickBallMoved,
      JoystickButtonPressed,
      JoystickButtonReleased,
      JoystickHatMoved,
      WindowResized
    ]
    
    @clock = Clock.new do |c|
      c.target_framerate = 40
      if c.respond_to? :calibrate
        c.calibrate 
        c.granularity = 2 if c.granularity < 2
      end
    end

    @auto_quit = @config_manager[:auto_quit]

    @hooks = {}
    @non_id_hooks = {}
  end
  
  # Sets the target framerate for the game. 
  # This setting controls how lock Clock#tick will delay.
  def framerate=(frame_rate)
    @clock.target_framerate = frame_rate
  end
  
  # Returns the target framerate.
  def framerate
    @clock.target_framerate
  end

  # This is where the queue gets pumped. This gets called from your game application.
  def main_loop(game)
    catch(:rubygame_quit) do
      loop do
        # add magic hooks
        @queue.each do |event|
          case event
          when KeyPressed
            case event.key
            when :f
              puts "Framerate:#{@clock.framerate}"
            when @auto_quit
              throw :rubygame_quit 
            end
          when QuitRequested
            throw :rubygame_quit
          end
          fire :event_received, event

          event_hooks = @hooks[event.class] 
          id = event.key if event.respond_to? :key

          if event.respond_to? :button
            id ||= (MOUSE_BUTTON_LOOKUP[event.button] or event.button)
          end

          unless id.nil?
            event_action_hooks = event_hooks[id] if event_hooks
            if event_action_hooks
              for callback in event_action_hooks
                callback.call event
              end
            end
          end
          
          non_id_event_hooks = @non_id_hooks[event.class]
          if non_id_event_hooks
            for callback in non_id_event_hooks
              callback.call event
            end
          end          
        end

        game.update @clock.tick
      end
    end
  end

  # registers a block to be called when matching events are pulled from the SDL queue.
  # ie 
  # input_manager.register_hook KeyPressed do |evt|
  #   # will be called on every key press
  # end
  # input_manager.register_hook KeyPressed, K_SPACE do |evt|
  #   # will be called on every spacebar key press
  # end
  def register_hook(event_class, *event_ids, &block)
    return unless block_given?
    listener = eval("self", block.binding) 
    _register_hook listener, event_class, *event_ids, &block
  end
  alias reg register_hook

  def _register_hook(listener, event_class, *event_ids, &block)
    return unless block_given?
    @hooks[event_class] ||= {}
    for event_id in event_ids
      @hooks[event_class][event_id] ||= []
      @hooks[event_class][event_id] << block
    end
    @non_id_hooks[event_class] ||= []
    if event_ids.empty?
      @non_id_hooks[event_class] << block
    end
    listener.when :remove_me do
      unregister_hook event_class, *event_ids, &block
    end
  end

  # unregisters a block to be called when matching events are pulled from the SDL queue.
  # ie 
  # input_manager.unregister_hook KeyPressed, :space, registered_block
  # also see InputManager#clear_hooks for clearing many hooks
  def unregister_hook(event_class, *event_ids, &block)
    @hooks[event_class] ||= {}
    for event_id in event_ids
      @hooks[event_class][event_id] ||= []
      @hooks[event_class][event_id].delete block if block_given?
    end
    if event_ids.empty?
      @hooks[event_class] ||= []
      @hooks[event_class].delete block if block_given?
    end
  end
  alias unreg unregister_hook


  # removes all blocks that are in the scope of listener's instance.
  # clears all listeners if listener is nil
  def clear_hooks(listener=nil)
    if listener
      for event_klass, id_listeners in @hooks
        for key in id_listeners.keys.dup
          id_listeners[key].delete_if do |block|
            eval('self',block.binding).equal?(listener)
          end
        end
      end
      
      for key in @non_id_hooks.keys.dup
        @non_id_hooks[key].delete_if do |block|
          eval('self',block.binding).equal?(listener)
        end
      end
    else
      @hooks = {}
      @non_id_hooks = {}
    end
  end

  # autohook a boolean to be set to true while a key is pressed
  def while_key_pressed(key, target, accessor)
    _register_hook target, KeyPressed, key do
      target.send accessor.to_s+"=", true
    end
    _register_hook target, KeyReleased, key do
      target.send accessor.to_s+"=", false
    end
  end

end
