module Conject
  class ObjectContext
    def has_config?(name)
      @object_configs.has_key?(name.to_sym)
    end
    def directly_has?(name)
      @cache.has_key?(name.to_sym) or has_config?(name.to_sym)
    end
    def get(name)
      name = name.to_sym
      return @cache[name] if @cache.has_key?(name)
      
      if !has_config?(name) and parent_context and parent_context.has?(name)
        return parent_context.get(name)
      else
        object = object_factory.construct_new(name,self)
        object.instance_variable_set(:@_conject_contextual_name, name.to_s)
        @cache[name] = object unless no_cache?(name)
        return object
      end
    end
  end
end
