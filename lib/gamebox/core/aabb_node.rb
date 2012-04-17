# This is the primary element in an AABBTree.
# It acts as both containing elements and leaf elements. Leaves have an @object, 
# containers have @a and @b nodes. All leaf nodes have a cached list of
# collisions that contain references to other nodes in the tree.
class AABBNode
  include AABBNodeDebugHelpers
  attr_accessor :bb, :a, :b, :parent, :object, :cached_collisions

  def initialize(parent, object, bb)
    @parent = parent
    @a = nil
    @b = nil

    @object = object
    @bb = bb
  end

  def insert_subtree(leaf)
    if leaf?
      new_node = AABBNode.new nil, nil, @bb.union_fast(leaf.bb)
      new_node.a = self
      new_node.b = leaf
      return new_node
    else
      cost_a = @b.bb.area + @a.bb.union_area(leaf.bb)
      cost_b = @a.bb.area + @b.bb.union_area(leaf.bb)

      if cost_a == cost_b
        cost_a = @a.proximity(leaf)
        cost_b = @b.proximity(leaf)
      end

      if cost_b < cost_a
        self.b = @b.insert_subtree leaf
      else
        self.a = @a.insert_subtree leaf
      end

      @bb.expand_to_include! leaf.bb
      return self
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
        leaf.parent.disown_child leaf
        return self
      end
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

  def other(child)
    @a == child ? @b : @a
  end

  def disown_child(leaf)
    value = other(leaf)
    raise "Internal Error: Cannot replace child of a leaf." if @parent.leaf?
    raise "Internal Error: AABBNode is not a child of parent." unless self == @parent.a || self == @parent.b

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
      node.bb.refit_for! node.a.bb, node.b.bb
      while node = node.parent
        node.bb.refit_for! node.a.bb, node.b.bb
      end
    end
  end

  def proximity(other_node)
    other_bb = other_node.bb
    (@bb.left + @bb.right - other_bb.left - other_bb.right).abs +
      (@bb.bottom + @bb.top - other_bb.bottom - other_bb.top).abs 
  end
end

