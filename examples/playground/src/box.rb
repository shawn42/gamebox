require 'actor'
require 'actor_view'

class Box < Actor

  has_behaviors :updatable, 
    :graphical,
    {:physical => {
      :shape => :poly, :verts => [ [-10,-10], [-10,10], [10,10], [10,-10] ],
      :mass => 1
    }}

  def setup
    puts "Setup, wtf?"
    @ttl = 3000
  end

  def update(delta)
    @ttl ||= 30000
    @ttl -= delta
    remove_self if @ttl < 0
  end

  def setup
    # register for events here
    # or pull stuff out of @opts
  end
end
