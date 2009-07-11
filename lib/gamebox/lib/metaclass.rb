class Object
  # Get a metaclass for this class
  def self.metaclass # :nodoc: 
    class << self; self; end; 
  end 
end
