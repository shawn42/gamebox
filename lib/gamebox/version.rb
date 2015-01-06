module Gamebox
  module VERSION #:nodoc:
    MAJOR = 0
    MINOR = 5
    TINY  = 3
    RC    = 0

    if RC > 0
      ARRAY = [MAJOR, MINOR, TINY, "rc#{RC}"]
    else
      ARRAY = [MAJOR, MINOR, TINY]
    end
    STRING = ARRAY.join('.')
  end
end

