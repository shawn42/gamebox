module AABBTreeDebugHelpers
  def valid?
    return true unless @root
    @root.contains_children?
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
end

module AABBNodeDebugHelpers

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

  def root
    node = self
    while node.parent
      node = node.parent
    end
    node
  end

end
