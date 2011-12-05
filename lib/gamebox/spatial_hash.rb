class SpatialHash

  attr_reader :cell_size, :buckets, :items, :moved_items
  attr_accessor :auto_resize

  def initialize(cell_size, resize = false)
    @cell_size = cell_size.to_i
    @items = {}
    @auto_resize = resize

    # TODO auto resize is broken atm
    if @auto_resize
      @total_w = 0
      @total_h = 0
    end
    @items = {}
    @buckets = {}
    rehash
  end

  def cell_size=(new_size)
    @cell_size = new_size.to_i
    rehash
  end

  def rehash
    @moved_items = {}
    # TODO WTF?
    return
    items = @items

    if @auto_resize
      # recommeded cell size == 2 x avg obj size
      if @total_w > 0 && items.size > 0
        avg_w = @total_w / items.size
        avg_h = @total_h / items.size

        @cell_size = (avg_w+avg_h).to_i
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
    _add item
  end

  def _add(item)
    buckets = lookup item
    @items[item] = buckets

    buckets.each do |bucket|
      bucket << item

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
    @moved_items.delete item
    _remove item
  end

  def _remove(item)
    buckets = @items.delete item
    if buckets
      buckets.each do |bucket|
        bucket.delete item
      end
    end
  end

  def lookup(item)
    w = item.width if item.respond_to? :width
    h = item.height if item.respond_to? :height

    w ||= 1
    h ||= 1

    x = item.x
    y = item.y
    min_x = bucket_cell_for x
    min_y = bucket_cell_for y
    if w == 1 && h == 1
      max_x = min_x
      max_y = min_y
    else
      max_x = bucket_cell_for x+w-1
      max_y = bucket_cell_for y+h-1
    end

    buckets = []
    bucket_x = min_x
    while bucket_x < max_x + 1 do 
      bucket_y = min_y
      while bucket_y < max_y + 1 do 
        @buckets[bucket_x] ||= {}
        @buckets[bucket_x][bucket_y] ||= SpatialBucket.new(bucket_x, bucket_y)
        buckets << @buckets[bucket_x][bucket_y]
        bucket_y += 1
      end
      bucket_x += 1
    end

    buckets
  end

  def bucket_cell_for(location)
    (location.to_i / cell_size).to_i
  end

  def items_at(x,y)
    bucket_x = bucket_cell_for x
    bucket_y = bucket_cell_for y
    if @buckets[bucket_x].nil? || @buckets[bucket_x][bucket_y].nil?
      return []
    else
      @buckets[bucket_x][bucket_y]
    end
  end

  def items_in(x,y,w,h)
    return items_at x, y if ((w.nil? || w == 1) && (h.nil? || w == 1))

    min_x = bucket_cell_for x
    min_y = bucket_cell_for y
    if w == 1 && h == 1
      max_x = min_x
      max_y = min_y
    else
      max_x = bucket_cell_for x+w-1
      max_y = bucket_cell_for y+w-1
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

    min_bucket_x = buckets.min_by{ |bucket| bucket.x }.x - dist
    min_bucket_y = buckets.min_by{ |bucket| bucket.y }.y - dist
    max_bucket_x = buckets.max_by{ |bucket| bucket.x }.x + dist
    max_bucket_y = buckets.max_by{ |bucket| bucket.y }.y + dist

    items = items_in_bucket_range min_bucket_x, min_bucket_y, max_bucket_x, max_bucket_y
    items-[item]
  end

end

