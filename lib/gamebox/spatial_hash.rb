class SpatialHash

  attr_reader :cell_size, :buckets, :items, :moved_items
  attr_accessor :auto_resize

  def initialize(cell_size, resize = false)
    @cell_size = cell_size.to_f
    @items = {}
    @auto_resize = resize

    if @auto_resize
      @total_w = 0
      @total_h = 0
    end
    @items = {}
    @buckets = {}
    rehash
  end

  def cell_size=(new_size)
    @cell_size = new_size
    rehash
  end

  def rehash
    @moved_items = {}
    return
    items = @items

    if @auto_resize
      # recommeded cell size == 2 x avg obj size
      if @total_w > 0 && items.size > 0
        avg_w = @total_w / items.size
        avg_h = @total_h / items.size

        @cell_size = (avg_w+avg_h)
      end

      @total_w = 0
      @total_h = 0
    end

    @items = {}
    @buckets = {}
    items.values.each do |item|
      add item
    end
  end

  # does not remove or add event handlers
  def move(item)
    @moved_items[item] = item
    _remove item
    _add item
  end

  def add(item)
    # TODO change these to one event? position_changed?
    item.when :x_changed do |old_x, new_x|
      move item
    end
    item.when :y_changed do |old_y, new_y|
      move item
    end
    item.when :remove_me do
      remove item
    end
    # item.when :width_changed do |old_w, new_w|
    #   @moved_items[item] = item
    #   remove item
    #   add item
    # end
    # item.when :height_changed do |old_h, new_h|
    #   @moved_items[item] = item
    #   remove item
    #   add item
    # end

    _add item
  end

  def _add(item)
    buckets = lookup item
    @items[item] = buckets
    buckets.each do |bucket|
      x,y = *bucket
      @buckets[x] ||= {}
      @buckets[x][y] ||= []
      target_bucket = @buckets[x][y]
      target_bucket << item 

      if @auto_resize
        w = item.width if item.respond_to? :width
        h = item.height if item.respond_to? :height
        w ||= 1
        h ||= 1
        @total_w += w 
        @total_h += h 
      end
    end
  end

  def remove(item)
    item.unsubscribe_all self
    @moved_items.delete item
    _remove item
  end

  def _remove(item)
    buckets = @items[item]
    buckets.each do |bucket|
      x,y = *bucket
      return if @buckets[x].nil? || @buckets[x][y].nil?
      @buckets[x][y].delete item
    end
    @items.delete item
  end

  def lookup(item)
    w = item.width if item.respond_to? :width
    h = item.height if item.respond_to? :height

    w ||= 1
    h ||= 1

    x = item.x
    y = item.y
    min_x, min_y = bucket_for x, y
    if w == 1 && h == 1
      max_x = min_x
      max_y = min_y
    else
      max_x, max_y = bucket_for x+w-1, y+h-1
    end

    buckets = []
    (max_x-min_x+1).times do |i|
      bucket_x = min_x + i
      (max_y-min_y+1).times do |j|
        buckets << [bucket_x,min_y+j] 
      end
    end

    buckets
  end

  def bucket_for(x,y)
    bucket_x = (x/cell_size).floor
    bucket_y = (y/cell_size).floor
    return [bucket_x, bucket_y]
  end
  
  def items_at(x,y)
    bucket_x = (x/@cell_size).floor
    bucket_y = (y/@cell_size).floor
    if @buckets[bucket_x].nil? || @buckets[bucket_x][bucket_y].nil?
      return []
    else
      @buckets[bucket_x][bucket_y]
    end
  end

  def items_in(x,y,w,h)
    return items_at x, y if ((w.nil? || w == 1) && (h.nil? || w == 1))

    min_x, min_y = bucket_for x, y
    if w == 1 && h == 1
      max_x = min_x
      max_y = min_y
    else
      max_x, max_y = bucket_for x+w-1, y+h-1
    end

    items_in_bucket_range min_x, min_y, max_x, max_y
  end

  def items_in_bucket_range(min_x,min_y,max_x,max_y)
    items = {}
    (min_x+1..(max_x+1)).each do |bucket_x|
      x_bucket = @buckets[bucket_x]

      if x_bucket
        (min_y+1..(max_y+1)).each do |bucket_y|
          objects = x_bucket[bucket_y]
          if objects
            objects.each do |item|
              items[item] = item
            end
          end
        end
      end
    end
    items.values
  end

  # will look dist number of cells around all the cells
  # occupied by the item
  def neighbors_of(item, dist=1)
    buckets = lookup(item)
    min_bucket_x, min_bucket_y = *buckets.first
    max_bucket_x, max_bucket_y = *buckets.last

    min_bucket_x = min_bucket_x-1
    min_bucket_y = min_bucket_y-1

    max_bucket_x = max_bucket_x+1
    max_bucket_y = max_bucket_y+1

    items = items_in_bucket_range min_bucket_x, min_bucket_y, max_bucket_x, max_bucket_y
    items-[item]
  end

end

