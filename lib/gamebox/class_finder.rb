module ClassFinder

  # Name is an underscore name string or symbol
  def find(name)
    klass = nil
    klass_name = Inflector.camelize(name)

    begin
      klass = Object.const_get(klass_name)
    rescue NameError => ex
      # not there yet
        log(:warn, ex)
      begin
        require "#{name}"
      rescue LoadError => ex
        # maybe its included somewhere else
        log(:warn, ex)
      ensure
        begin
          klass = Object.const_get(klass_name)
        rescue Exception => ex
          # leave this alone.. maybe there isnt a NameView
          log(:warn, ex)
          
        end
      end
    end
    
    klass
  end
  module_function :find

end
