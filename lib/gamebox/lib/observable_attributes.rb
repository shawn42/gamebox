module ObservableAttributes

  def has_attributes(*names)
    if names.first.is_a? Hash
      names.first.each do |name, default|
        has_attribute name, default
      end
    else
      names.each do |name|
        has_attribute name
      end
    end
  end

  def has_attribute(name, value=nil)
    @evented_attributes ||= []
    unless has_attribute? name
      @evented_attributes << name
      self.metaclass.send :kvo_attr_accessor, name
      self.define_singleton_method "#{name}?" do
        self.send name
      end
      self.send("#{name}=", value)
    end
  end

  def has_attribute?(name)
    @evented_attributes && @evented_attributes.include?(name)
  end

  def attributes
    {}.tap do |atts|
      if @evented_attributes
        @evented_attributes.each do |name|
          atts[name] = self.send name
        end
      end
    end
  end

  def self.included(klass)
    klass.instance_eval do
      include Kvo
      def has_attribute(name)
        kvo_attr_accessor name
      end
    end

  end

end
