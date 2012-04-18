module EventedAttributes

  def has_attributes(*names)
    if names.first.is_a? Hash
      names.each do |name, default|
        has_attribute name, default
      end
    else
      names.each do |name|
        has_attribute name
      end
    end
  end

  def has_attribute(name, value=nil)
    unless has_attribute? name
      self.metaclass.send :kvo_attr_accessor, name
      self.send("#{name}=", value)
    end
  end

  def has_attribute?(name)
    respond_to? name
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
