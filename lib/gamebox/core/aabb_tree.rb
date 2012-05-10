# AABBTree is a binary tree where each node has a bounding box that contains
# its children's bounding boxes. It extrapolates and expands the node bounding
# boxes before inserting to lower the amount of updates to the tree structure.
# It caches all leaf node collisions for quick lookup.
class AABBTree
  include AABBTreeDebugHelpers
  DEFAULT_BB_SCALE = 1
  VELOCITY_SCALE = 3

  attr_reader :items
  extend Forwardable
  def_delegators :@items, :size, :include?

  def initialize
    @items = {}
    @root = nil
  end

  def query(search_bb, &callback)
    return unless @root
    @root.query_subtree search_bb, &callback
  end

  def collisions(item, &blk)
    leaf = @items[item]
    return unless leaf && leaf.cached_collisions
    leaf.cached_collisions.each do |collider|
      blk.call collider.object
    end
  end

  def insert(item)
    raise "Adding an existing item, please use update" if @items[item]
    leaf = AABBNode.new nil, item, calculate_bb(item)
    @items[item] = leaf
    insert_leaf leaf
  end

  def remove(item)
    leaf = @items.delete item
    if leaf
      @root = @root.remove_subtree leaf 
      clear_cached_collisions leaf
    end
  end

  def update(item)
    node = @items[item]
    if node && node.leaf?
      new_bb = calculate_bb(item)
      unless node.bb.contain? item.bb
        node.bb = new_bb
        clear_cached_collisions node
        @root = @root.remove_subtree node
        insert_leaf node
      end
    end
  end

  private

  def clear_cached_collisions(leaf)
    cached_collisions = leaf.cached_collisions

    if cached_collisions
      leaf.cached_collisions = nil
      cached_collisions.each do |other|
        other.cached_collisions.delete leaf
      end
    end
  end

  def build_cached_collisions(leaf)
    each_leaf do |other|
      if leaf != other && leaf.bb.collide_rect?(other.bb)
        leaf.cached_collisions ||= []
        other.cached_collisions ||= []
        leaf.cached_collisions << other 
        other.cached_collisions << leaf
      end
    end
  end

  def insert_leaf(leaf)
    if @root
      @root = @root.insert_subtree leaf
    else
      @root = leaf
    end
    build_cached_collisions leaf
  end

  def expand_bb_by!(bb, percent)
    new_w = bb.w * percent
    new_h = bb.h * percent
    hw = new_w / 2.0
    hh = new_h / 2.0

    bb.x = (bb.x - hw).ceil
    bb.y = (bb.y - hh).ceil
    bb.w = (bb.w + new_w).ceil
    bb.h = (bb.h + new_h).ceil
    bb
  end

  def project_bb_by_velocity!(bb, velocity_vector)
    future_vector = velocity_vector * VELOCITY_SCALE
    projected_bb = [bb.x + velocity_vector.x,
                    bb.y + velocity_vector.y,
                    bb.w, bb.h ]

    u_bb = bb.union_fast(projected_bb)
    bb.x = u_bb.x
    bb.y = u_bb.y
    bb.w = u_bb.w
    bb.h = u_bb.y
  end

  def calculate_bb(item)
    if item.respond_to? :bb
      bb = item.bb.dup
      project_bb_by_velocity!(bb, item.velocity) if item.respond_to? :velocity
      expand_bb_by!(bb, DEFAULT_BB_SCALE)
    else
      if item.respond_to? :width
        w = item.width
        h = item.height
      elsif item.respond_to? :radius
        w = item.radius * 2
        h = item.radius * 2
      end
      w ||= 2
      h ||= 2

      expand_bb_by!(Rect.new item.x, item.y, w, h, DEFAULT_BB_SCALE)
    end
  end
end

