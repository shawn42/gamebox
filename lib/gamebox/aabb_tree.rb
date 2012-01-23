# TODO
# keep NodePool around to reduce object churn
# force all bb to be in integers? (rect may do this for us)
# have a dot file output for debugging
# optimize
# balance
class AABBTree
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

  def each(&blk)
    return unless @root
    query @root.bb, &blk
  end

  def insert(item)
    leaf = @items[item.object_id]
    if leaf
      reindex leaf
    else
      leaf = Node.new nil, item, calculate_bb(item)
      @items[item.object_id] = leaf
      insert_leaf leaf
    end
    # leaf->STAMP = GetStamp(tree);
    # LeafAddPairs(leaf, tree);
    # IncrementStamp(tree);
  end

  def insert_leaf(leaf)
    if @root
      @root = @root.insert_subtree leaf
    else
      @root = leaf
    end
  end

  def remove(item)
    leaf = @items.delete item.object_id
    # PairsClear
    @root = @root.remove_subtree leaf if leaf
  end

  def reindex(item)
    node = @items[item.object_id]
    if node && node.leaf?
      new_bb = item.bb #calculate_bb(item)
      unless node.bb.contain? new_bb
        # use velocity vector to extrap
        # 10% bigger
        horizontal_growth = (new_bb.w * 0.1).ceil
        vertical_growth = (new_bb.h * 0.1).ceil
        node.bb[0] = new_bb.x - horizontal_growth
        node.bb[1] = new_bb.y - vertical_growth
        node.bb[2] = new_bb.w + 2*horizontal_growth
        node.bb[3] = new_bb.h + 2*vertical_growth

        @root = @root.remove_subtree node
        insert_leaf node
      end
    end
  end

  def calculate_bb(item)
    # TODO extrude and whatnot
    if item.respond_to? :bb
      item.bb
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

      horizontal_growth = (w * 0.05).ceil
      vertical_growth = (h * 0.05).ceil

      Rect.new item.x - horizontal_growth, item.y - vertical_growth,
          w + 2*horizontal_growth, h + 2*vertical_growth
    end
  end

  def neighbors_of(item, &blk)
    leaf = @items[item.object_id]
    return unless leaf
    @root.query_subtree calculate_bb(item), &blk
  end

  def valid?
    @root.contains_children?
  end

  class Node
    attr_accessor :bb, :a, :b, :parent, :object

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
          # tie breaker
          # check proximity
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
      while node = node.parent
        node.bb = union_bb(@a.bb, @b.bb)
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
        Parent: #{@parent.object_id}
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
        Parent: #{@parent.object_id}
        """
      end
    end
  end

end
