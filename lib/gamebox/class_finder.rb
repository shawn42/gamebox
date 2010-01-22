module ClassFinder

  # Name is an underscore name string or symbol
  def find(name)
    klass = nil
    klass_name = Inflector.camelize(name)

    begin
      klass = Object.const_get(klass_name)
    rescue NameError
      # not there yet
      begin
        require "#{name}"
      rescue LoadError => ex
        # maybe its included somewhere else
      ensure
        klass = Object.const_get(klass_name)
      end
    end
    
    klass
  end
  module_function :find

end
