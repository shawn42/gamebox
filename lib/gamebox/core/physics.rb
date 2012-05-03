if defined? CP
  ZERO_VEC_2 = vec2(0,0) unless defined? ZERO_VEC_2
  def vec2(*args)
    CP::Vec2.new *args
  end

  class CP::Shape::Circle
    attr_accessor :actor
  end
  class CP::Shape::Poly
    attr_accessor :actor
  end
  class CP::Shape::Segment
    attr_accessor :actor
  end

else
  ZERO_VEC_2 = Ftor.new(0,0)
  def vec2(*args)
    Ftor.new *args
  end
end
