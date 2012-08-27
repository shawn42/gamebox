if defined? CP
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
  def vec2(*args)
    Vector2.new *args
  end
end

ZERO_VEC_2 = vec2(0,0)
