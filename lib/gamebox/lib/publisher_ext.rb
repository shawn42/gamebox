module Publisher
  module InstanceMethods
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
