module ClassFinder

  # Name is an underscore name string or symbol
  def find(name)
    klass = nil
    klass_name = Inflector.camelize(name)

    klass = Object.const_get(klass_name) rescue
    
    klass
  end
  module_function :find

end
