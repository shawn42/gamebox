class AABBNode
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
      # TODO refit_for! node.bb, node.a.bb, node.b.bb
      node.bb = node.a.bb.union_fast(node.b.bb)
      while node = node.parent
        node.bb = node.a.bb.union_fast(node.b.bb)
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

end
