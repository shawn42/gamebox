# TODO
# keep NodePool around to reduce object churn
# force all bb to be in integers? (rect may do this for us)
# have a dot file output for debugging
# optimize
# balance
class AABBTree
  attr_reader :items
  def initialize
    @items = {}
  end

  def insert(item)
    bb = calculate_bb item
    leaf = Node.new nil, item, item.bb
    @items[item] = leaf
    if @root
      @root = @root.insert_subtree leaf
    else
      @root = leaf
    end
    # leaf->STAMP = GetStamp(tree);
    # LeafAddPairs(leaf, tree);
    # IncrementStamp(tree);
  end

  def remove(item)
    leaf = @items.delete item
    # PairsClear
    @root = @root.remove_subtree leaf if leaf
  end

  def reindex(item)
    leaf = @items.delete item
    if leaf.leaf?
      unless leaf.bb.contain? item.bb
        leaf.bb = calculate_bb item
        @root.remove_subtree leaf
        @root.insert_subtree leaf
        true
      end
      false
    end
  end

  def calculate_bb(item)
    # TODO extrude and whatnot
    if item.respond_to? :bb
      item.bb
    else
      if item.respond_to? :width
        w = item.respond_to?(:width) ? item.width : 1
        h = item.respond_to?(:height) ? item.height : 1
      elsif item.respond_to? :radius
        w = h = item.radius * 2
      end
      Rect.new item.x, item.y, w, h
    end
  end

  def neighbors_of(item, &blk)
    query calculate_bb(item), &blk
  end

  def size
    @items.size
  end

  def to_s
    @root.to_s
  end

  class Node
    attr_accessor :bb, :a, :b, :parent

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
        new_node = Node.new nil, nil, @bb.union(leaf.bb)
        new_node.a = self
        new_node.b = leaf
        return new_node
      else
        cost_a = @b.bb.area + @a.bb.union(leaf.bb).area
        cost_b = @a.bb.area + @b.bb.union(leaf.bb).area

        if cost_a == cost_b
          # tie breaker
          # check proximity
        end

        if cost_b < cost_a
          self.b = @b.insert_subtree leaf
        else
          self.a = @a.insert_subtree leaf
        end

        @bb.union! leaf.bb
        return self
      end
    end

    def other(child)
      @a == child ? @b : @a
    end

    # horrible name!!
    def hand_off_child(leaf)
      child = @parent
      dad = child.parent
      raise "Internal Error: Cannot replace child of a leaf." if dad.leaf?
      raise "Internal Error: Node is not a child of parent." unless child == dad.a || child == dad.b

      if dad.a == child
        dad.a = leaf
      else
        dad.b = leaf
      end

      parent.update_bb
    end

    def update_bb
      node = self
      while node = node.parent
        node.bb = @a.bb.union(@b.bb)
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
          hand_off_child other(leaf)
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
        BB: #{@bb}
        A: #{@a}
        B: #{@b}
        Parent: #{@parent.object_id}
        """
      end
    end

  end

  # query the tree
  def query(search_bb, &callback)
    return unless @root
    @root.query_subtree search_bb, &callback
  end
end
