

class SpatialStagehand < Stagehand
  DEFAULT_PARAMS = {
    :cell_size => 50
  }
  def setup
    @dead_actors = []
    merged_opts = DEFAULT_PARAMS.merge opts
    @spatial_actors = SpatialHash.new merged_opts[:cell_size]
    # TODO
    # delegate :items, :cell_size, :to => @spatial_actors
  end

  def cell_size
    @spatial_actors.cell_size
  end

  def cell_size=(new_size)
    @spatial_actors.cell_size = new_size
  end

  def auto_resize=(val)
    @spatial_actors.auto_resize = val
  end

  def auto_resize
    @spatial_actors.auto_resize
  end
  
  def moved_items
    @spatial_actors.moved_items.values
  end

  def items
    @spatial_actors.items.values
  end

  def buckets
    @spatial_actors.buckets
  end

  def add(actor)
    # TODO change these to one event? position_changed?
    # item.when :width_changed do |old_w, new_w|
    # item.when :height_changed do |old_h, new_h|

    actor.when :x_changed do |old_x, new_x|
      move actor
    end
    actor.when :y_changed do |old_y, new_y|
      move actor
    end
    actor.when :remove_me do
      remove actor
    end
    @spatial_actors.add actor
  end

  def remove(actor)
    @dead_actors << actor
    @spatial_actors.remove actor
  end

  def move(actor)
    @spatial_actors.move actor
  end

  def items_at(x,y)
    @spatial_actors.items_at x, y
  end

  def items_in(x,y,w,h)
    @spatial_actors.items_in x, y, w, h
  end

  def neighbors_of(item, dist=1)
    @spatial_actors.neighbors_of item, dist
  end

  def update(time)
    @dead_actors.each do |actor|
      actor.unsubscribe_all self
    end
    @dead_actors = []
  end

end
