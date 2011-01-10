unless Float.const_defined? "INFINITY"
  class Float
    INFINITY = 1.0/0.0
  end
end
