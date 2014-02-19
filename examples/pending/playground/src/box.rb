


class Box < Actor

  has_behaviors :updatable, 
    :graphical,
    {:physical => {
      :shape => :poly, :verts => [ [-15,-15], [-15,15], [15,15], [15,-15] ],
      :mass => 1,
      :elasticity => 1.0,
      :friction => 0.0
    }}

  def setup
    @ttl = 30000
  end

  def update(delta)
    @ttl -= delta
    remove_self if @ttl < 0
  end
end
