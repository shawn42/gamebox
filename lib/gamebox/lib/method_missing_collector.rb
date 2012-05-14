class MethodMissingCollector
  attr_accessor :calls
  def initialize
    @calls = {}
  end

  def method_missing(name, *args)
    @calls[name] = args
  end
end
