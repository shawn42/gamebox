require 'publisher'
require 'hooked_gosu_window'

# InputManager handles the pumping for events and distributing of said events.
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
# Don't forget to unreg for these things between stages, 
# since the InputManager is shared across stages.
class InputManager 
  extend Publisher
  can_fire :key_up, :event_received

  attr_accessor :window

  # lookup map for mouse button clicks
  MOUSE_BUTTON_LOOKUP = {
    MsLeft   => :left,
    MsMiddle => :middle,
    MsRight  => :right,
  }

  MOUSE_IDS = [
    MsLeft, MsMiddle, MsRight, MsWheelUp, MsWheelDown
  ]

  constructor :config_manager

  # Sets up the clock and main event loop. You should never call this method, 
  # as this class should be initialized by diy.
  def setup
    width, height = @config_manager[:screen_resolution]
    fullscreen = @config_manager[:fullscreen]
    @window = HookedGosuWindow.new width, height, fullscreen

    @auto_quit = instance_eval(@config_manager[:auto_quit])

    @hooks = {}
    @non_id_hooks = {}
  end

  # This gets called from game app and sets up all the
  # events. (also shows the window)
  def main_loop(game)

    @window.when :button_up do |button_id|
      _handle_event button_id
    end
    @window.when :button_down do |button_id|
      _handle_event button_id
    end
    @window.when :update do |millis|
      # TODO if mouse has moved, fire mouse motion?
      game.update millis
    end
    @window.when :draw do 
      game.draw 
    end

    @window.show
  end

  def _handle_event(gosu_id) #:nodoc:
    @window.close if gosu_id == @auto_quit
    return
#    case event
#    when KeyPressed
#      case event.key
#      when @auto_quit
#        @window.close
#      end
#    end
#    fire :event_received, event
#
#    # fix for pause bug?
#    @hooks ||= {}
#    @non_id_hooks ||= {}
#
#    event_hooks = @hooks[event.class] 
#    id = event.key if event.respond_to? :key
#
#    if event.respond_to? :button
#      id ||= (MOUSE_BUTTON_LOOKUP[event.button] or event.button)
#    end
#
#    unless id.nil?
#      event_action_hooks = event_hooks[id] if event_hooks
#      if event_action_hooks
#        for callback in event_action_hooks
#          callback.call event
#        end
#      end
#    end
#    
#    non_id_event_hooks = @non_id_hooks[event.class]
#    if non_id_event_hooks
#      for callback in non_id_event_hooks
#        callback.call event
#      end
#    end          
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
    if listener.respond_to?(:can_fire?) && listener.can_fire?(:remove_me)
      listener.when :remove_me do
        unregister_hook event_class, *event_ids, &block
      end
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
      target.send "#{accessor}=", true
    end
    _register_hook target, KeyReleased, key do
      target.send "#{accessor}=", false
    end
  end

  def pause
    @paused_hooks = @hooks
    @paused_non_id_hooks = @non_id_hooks
    @hooks = {}
    @non_id_hooks = {}
  end

  def unpause
    @hooks = @paused_hooks
    @non_id_hooks = @paused_non_id_hooks
    @paused_hooks = nil
    @paused_non_id_hooks = nil
  end

end
