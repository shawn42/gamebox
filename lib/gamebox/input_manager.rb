require 'publisher'

# looks like theres a bug in Gosu
KbRangeBegin = 0

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

  DOWN_EVENTS = [:mouse_down, :keyboard_down, :game_pad_down]
  UP_EVENTS = [:mouse_up, :keyboard_up, :game_pad_up]

  attr_accessor :window
  constructor :config_manager, :wrapped_screen

  # Sets up the clock and main event loop. You should never call this method, 
  # as this class should be initialized by diy.
  def setup
    @window = @wrapped_screen.screen

    auto_quit = @config_manager[:auto_quit]
    @auto_quit = instance_eval(auto_quit) if auto_quit

    @hooks = {}
    @non_id_hooks = {}
    @down_ids = {}
  end

  def show
    # Does not return, Gosu uses this to pop up the window
    # This must be last in the method
    @window.show
  end

  def fire_event(event)
    fire :event_received, event

    # fix for pause bug?
    @hooks ||= {}
    @non_id_hooks ||= {}

    event_hooks = @hooks[event[:callback_key]] 
    gosu_id = event[:id]

    unless gosu_id.nil?
      event_action_hooks = event_hooks[gosu_id] if event_hooks
      if event_action_hooks
        for callback in event_action_hooks
          callback.call event
        end
      end
    end

    non_id_event_hooks = @non_id_hooks[event[:callback_key]]
    if non_id_event_hooks
      for callback in non_id_event_hooks
        callback.call event
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
    event_class = :down if DOWN_EVENTS.include? event_class
    event_class = :up if UP_EVENTS.include? event_class
    return unless block_given?
    listener = eval("self", block.binding) 
    _register_hook listener, event_class, *event_ids, &block
  end
  alias reg register_hook

  def _register_hook(listener, event_class, *event_ids, &block)
    return unless block_given?
    @hooks[event_class] ||= {}
    for event_id in event_ids
      @uses_mouse = true if event_id >= MsRangeBegin && event_id <= MsRangeEnd
      @hooks[event_class][event_id] ||= []
      @hooks[event_class][event_id] << block
    end
    @non_id_hooks[event_class] ||= []
    if event_ids.empty?
      @uses_mouse = true
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
    event_class = :down if DOWN_EVENTS.include? event_class
    event_class = :up if UP_EVENTS.include? event_class
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

  # autohook a boolean to be set to true while any of the keys are pressed
  def while_pressed(id_or_ids, target, accessor)
    ids = [id_or_ids].flatten
    ids.each do |id|
      _register_hook target, :down, id do
        target.send "#{accessor}=", true
      end

      _register_hook target, :up, id do
        target.send "#{accessor}=", false if (@down_ids.keys & ids).size == 0
      end
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

  def register(game)
    @window.when :button_up do |button_id|
      handle_event button_id, :up
    end
    @window.when :button_down do |button_id|
      handle_event button_id, :down
    end

    @window.when :update do |millis|

      if @uses_mouse
        @last_mouse_x ||= mouse_x
        @last_mouse_y ||= mouse_y

        x_diff = @last_mouse_x - mouse_x
        y_diff = @last_mouse_y - mouse_y

        unless x_diff < 0.1 && x_diff > -0.1 && y_diff < 0.1 && y_diff > -0.1
          handle_event nil, :motion

          @last_mouse_x = mouse_x
          @last_mouse_y = mouse_y
        end
      end

      game.update millis
    end
    @window.when :draw do 
      game.draw 
    end
  end

  private

  def handle_event(gosu_id, action) #:nodoc:
    @window.close if @auto_quit && gosu_id == @auto_quit
    if action == :down
      @down_ids[gosu_id] = true 
    else
      @down_ids.delete gosu_id
    end

    event_data = nil
    mouse_dragged = false

    callback_key = action
    if gosu_id.nil?
      event_type = :mouse_motion
      callback_key = :mouse_motion
      @mouse_dragging = true if @mouse_down
      event_data = [mouse_x, mouse_y]
    elsif gosu_id >= MsRangeBegin && gosu_id <= MsRangeEnd
      event_type = :mouse
      event_data = [mouse_x, mouse_y]
      if action == :up
        # callback_key = :mouse_up
        @mouse_down = false
        mouse_dragged = true if @mouse_dragging
        @mouse_dragging = false
      else
        # callback_key = :mouse_down
        @mouse_down = true
        @last_click_x = mouse_x
        @last_click_y = mouse_y
      end
    elsif gosu_id >= KbRangeBegin && gosu_id <= KbRangeEnd
      event_type = :keyboard
    elsif gosu_id >= GpRangeBegin && gosu_id <= GpRangeEnd
      event_type = :game_pad
    end

    # single threaded.. keep same event
    @event ||= {}
    @event[:type] = event_type
    @event[:id] = gosu_id
    @event[:action] = action
    @event[:callback_key] = callback_key
    @event[:data] = event_data

    fire_event(@event)

    if mouse_dragged
      drag_data = {:to => [mouse_x, mouse_y], :from => [@last_click_x, @last_click_y]}
      @event[:data] = drag_data
      @event[:callback_key] = :mouse_drag
      fire_event(@event)
    end
  end


  def mouse_x
    @window.mouse_x
  end

  def mouse_y
    @window.mouse_y
  end

end
