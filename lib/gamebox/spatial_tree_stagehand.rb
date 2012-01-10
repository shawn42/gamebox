

class SpatialTreeStagehand < Stagehand
  attr_reader :moved_items

  def setup
    @dead_actors = []
    @moved_items = {}
    @tree = AABBTree.new
  end

  def items
    @tree.items.values
  end

  def buckets
    @tree.buckets
  end

  def add(actor)
    # TODO change these to one event? position_changed?
    # item.when :width_changed do |old_w, new_w|
    # item.when :height_changed do |old_h, new_h|

    actor.when :x_changed do |old_x, new_x|
      @moved_items[actor] = actor
    end
    actor.when :y_changed do |old_y, new_y|
      @moved_items[actor] = actor
    end
    actor.when :remove_me do
      remove actor
    end
    @tree.add actor
  end

  def remove(actor)
    @dead_actors << actor
    @moved_items.delte actor
    @tree.remove actor
  end

  def update(time)
    @dead_actors.each do |actor|
      actor.unsubscribe_all self
    end
    @dead_actors = []
    @moved_items = {}
  end

end
