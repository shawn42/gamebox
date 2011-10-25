

class SpatialStagehand < Stagehand

  DEFAULT_PARAMS = {
    :cell_size => 50
  }
  def setup
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
  
  def items
    @spatial_actors.moved_items.values
  end

  def buckets
    @spatial_actors.buckets
  end

  def add(actor)
    @spatial_actors.add actor
  end

  def remove(actor)
    @spatial_actors.remove actor
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

end
