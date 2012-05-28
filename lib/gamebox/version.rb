module Gamebox
  module VERSION #:nodoc:
    MAJOR = 0
    MINOR = 4
    TINY  = 0
    RC    = 4

    if RC > 0
      ARRAY = [MAJOR, MINOR, TINY, "rc#{RC}"]
    else
      ARRAY = [MAJOR, MINOR, TINY]
    end
    STRING = ARRAY.join('.')
  end
end

