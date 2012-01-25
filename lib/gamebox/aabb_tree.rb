# TODO
# keep NodePool around to reduce object churn
# have a dot file output for debugging
# optimize
# balance

def min(a,b)
  a < b ? a : b
end
def max(a,b)
  a > b ? a : b
end

def union_bb_area(bb, rect)
  rleft = bb.left
  rtop = bb.top
  rright = bb.right
  rbottom = bb.bottom
  r2 = Rect.new_from_object(rect)

  rleft = min(rleft, r2.left)
  rtop = min(rtop, r2.top)
  rright = max(rright, r2.right)
  rbottom = max(rbottom, r2.bottom)

  (rright - rleft) * (rbottom - rtop)
end

def union_bb(bb, rect)
  # TODO can this be changed to actually update bb?
  rleft = bb.left
  rtop = bb.top
  rright = bb.right
  rbottom = bb.bottom
  r2 = Rect.new_from_object(rect)

  rleft = min(rleft, r2.left)
  rtop = min(rtop, r2.top)
  rright = max(rright, r2.right)
  rbottom = max(rbottom, r2.bottom)

  Rect.new(rleft, rtop, rright - rleft, rbottom - rtop)
end
class AABBTree
  DEFAULT_BB_SCALE = 1
  attr_reader :items
  extend Forwardable

  def_delegators :@items, :size, :include?
  def_delegators :@root, :to_s

  def initialize
    @items = {}
    @root = nil
  end

  # query the tree
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
      leaf = Node.new nil, item, calculate_bb(item)
      @items[item] = leaf
      insert_leaf leaf
    end
  end

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
        @root = @root.remove_subtree node
        insert_leaf node
      end
    end
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
    projected_bb = [bb.x + velocity_vector.x,
                    bb.y + velocity_vector.y,
                    bb.w, bb.h ]

    u_bb = union_bb(bb, projected_bb)
    bb.x = u_bb.x
    bb.y = u_bb.y
    bb.w = u_bb.w
    bb.h = u_bb.y
  end

  def calculate_bb(item)
    # TODO extrude and whatnot
    if item.respond_to? :bb
      # TODO move these methods to Rect?
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

  def valid?
    return true unless @root
    @root.contains_children?
  end

  class Node
    attr_accessor :bb, :a, :b, :parent, :object, :pairs

    def initialize(parent, object, bb)
      @parent = parent
      @a = nil
      @b = nil

      @object = object
      @bb = bb
    end

    def leaf?
      @object
    end

    def a=(new_a)
      @a = new_a
      @a.parent = self
    end

    def b=(new_b)
      @b = new_b
      @b.parent = self
    end

    def insert_subtree(leaf)
      if leaf?
        # node new
        new_node = Node.new nil, nil, union_bb(@bb, leaf.bb) 
        new_node.a = self
        new_node.b = leaf
        return new_node
      else
        cost_a = @b.bb.area + union_bb_area(@a.bb, leaf.bb)
        cost_b = @a.bb.area + union_bb_area(@b.bb, leaf.bb)

        if cost_a == cost_b
          cost_a = @a.proximity(leaf)
          cost_b = @b.proximity(leaf)
        end

        if cost_b < cost_a
          self.b = @b.insert_subtree leaf
        else
          self.a = @a.insert_subtree leaf
        end

        @bb = union_bb(@bb, leaf.bb)
        # TODO expand_to_include leaf.bb
        return self
      end
    end

    def other(child)
      @a == child ? @b : @a
    end

    def root
      node = self
      while node.parent
        node = node.parent
      end
      node
    end

    # horrible name!!
    def hand_off_child(leaf)
      value = other(leaf)
      raise "Internal Error: Cannot replace child of a leaf." if @parent.leaf?
      raise "Internal Error: Node is not a child of parent." unless self == @parent.a || self == @parent.b

      if @parent.a == self
        @parent.a = value
      else
        @parent.b = value
      end

      @parent.update_bb
    end

    def update_bb
      node = self
      unless node.leaf?
        node.bb = union_bb(node.a.bb, node.b.bb)
        while node = node.parent
          node.bb = union_bb(node.a.bb, node.b.bb)
        end
      end
    end

    def remove_subtree(leaf)
      if leaf == self
        return nil
      else
        if leaf.parent == self
          other_child = other(leaf)
          other_child.parent = @parent
          return other_child
        else
          leaf.parent.hand_off_child leaf
          return self
        end
      end
    end

    def proximity(other_node)
      other_bb = other_node.bb
      (@bb.left + @bb.right - other_bb.left - other_bb.right).abs +
      (@bb.bottom + @bb.top - other_bb.bottom - other_bb.top).abs 
    end

    def each_node(&blk)
      blk.call self
      unless leaf?
        @a.each_node &blk
        @b.each_node &blk
      end
    end

    def each_leaf(&blk)
      if leaf?
        blk.call self
      else leaf?
        @a.each_leaf &blk
        @b.each_leaf &blk
      end
    end

    def query_subtree(search_bb, &blk)
      if @bb.collide_rect? search_bb
        if leaf?
          blk.call @object
        else
          @a.query_subtree search_bb, &blk
          @b.query_subtree search_bb, &blk
        end
      end
    end

    def contains_children?
      if leaf?
        true
      else
        @bb.contain?(a.bb) &&
        @bb.contain?(b.bb) &&
        @a.contains_children? &&
        @b.contains_children?
      end
    end

    def to_s
      if leaf?
        """
        Leaf #{object_id}
        BB: #{@bb}
        Parent: #{@parent}
        Object: #{@object}
        """
      else
        """
        Container #{object_id}
        UnionedBB: #{union_bb(@a.bb, @b.bb)}
        ACollide?: #{@bb.collide_rect?(@a.bb)}
        BCollide?: #{@bb.collide_rect?(@b.bb)}
        BB: #{@bb}
        A: #{@a}
        B: #{@b}
        Parent: #{@parent}
        """
      end
    end
  end

end
