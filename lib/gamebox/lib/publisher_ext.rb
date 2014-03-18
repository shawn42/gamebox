module Publisher
  module InstanceMethods
    def ensure_valid(*args)
      true
    end
    def can_fire?(event) 
      # events = self.class.published_events
      # return true if events == :any_event_is_ok
      # return false unless events and events.include?(event)
      return true
    end
    def unsubscribe_all(listener)
      if @subscriptions
        for event in @subscriptions.keys
          @subscriptions[event].delete_if do |block|
            eval('self',block.binding).equal?(listener)
          end
        end
      end
    end
  end
end
