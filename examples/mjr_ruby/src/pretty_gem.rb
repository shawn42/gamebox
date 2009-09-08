require 'actor'

class PrettyGem < Actor
  
  has_behavior :graphical

  def setup
    # register for events here
    # or pull stuff out of @opts
  end
end
