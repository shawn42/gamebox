class AABBTree
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

  def potential_collisions(item, &blk)
    leaf = @items[item]
    return unless leaf && leaf.pairs
    leaf.pairs.each do |collider|
      blk.call collider.object
    end
  end

  def each(&blk)
    return unless @root
    query @root.bb, &blk
  end

  def each_node(&blk)
    return unless @root
    @root.each_node &blk
  end

  def each_leaf(&blk)
    return unless @root
    @root.each_leaf &blk
  end

  def insert(item)
    leaf = @items[item]
    if leaf
      reindex leaf
    else
      leaf = AABBNode.new nil, item, calculate_bb(item)
      @items[item] = leaf
      insert_leaf leaf
    end
  end

  def remove(item)
    leaf = @items.delete item
    @root = @root.remove_subtree leaf if leaf
    clear_pairs leaf
  end

  def reindex(item)
    node = @items[item]
    if node && node.leaf?
      new_bb = calculate_bb(item)
      unless node.bb.contain? item.bb
        node.bb = new_bb
        clear_pairs node
        @root = @root.remove_subtree node
        insert_leaf node
      end
    end
  end

  def valid?
    return true unless @root
    @root.contains_children?
  end

  private

  def clear_pairs(leaf)
    pairs = leaf.pairs

    if pairs
      leaf.pairs = nil
      pairs.each do |other|
        other.pairs.delete leaf
      end
    end
  end

  def build_pairs(leaf)
    each_leaf do |other|
      if leaf != other && leaf.bb.collide_rect?(other.bb)
        leaf.pairs ||= []
        other.pairs ||= []
        leaf.pairs << other 
        other.pairs << leaf
      end
    end
  end

  def insert_leaf(leaf)
    if @root
      @root = @root.insert_subtree leaf
    else
      @root = leaf
    end
    build_pairs leaf
  end

  def expand_bb_by!(bb, percent)
    new_w = bb.w * percent
    new_h = bb.h * percent
    hw = new_w / 2.0
    hh = new_h / 2.0

    bb.x = (bb.x - hw).ceil
    bb.y = (bb.y - hh).ceil
    bb.w = (bb.w + new_w).ceil
    bb.h = (bb.w + new_h).ceil
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
