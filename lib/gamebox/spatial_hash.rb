class SpatialHash

  attr_accessor :cell_size

  def initialize(cell_size)
    @cell_size = cell_size.to_f
    @buckets = {}
    @items = []
  end

  def rehash
    items = @items
    @items = []
    @buckets = {}
    items.each do |item|
      add item
    end
  end

  def add(item)
    buckets = lookup item
    buckets.each do |bucket|
      x,y = *bucket
      @buckets[x] ||= {}
      @buckets[x][y] ||= []
      target_bucket = @buckets[x][y]
      unless target_bucket.include? item
        target_bucket << item 
        @items << item
      end
    end
  end

  def lookup(item)
    w = 1
    h = 1
    w = item.width if item.respond_to? :width
    h = item.height if item.respond_to? :height
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
      (max_y-min_y+1).times do |j|
        buckets << [min_x+i,min_y+j] 
      end
    end

    buckets
  end

  def bucket_for(x,y)
    bucket_x = (x/cell_size).floor
    bucket_y = (y/cell_size).floor
    return [bucket_x, bucket_y]
  end

  def remove(item)
    buckets = lookup item
    buckets.each do |bucket|
      x,y = *bucket
      return if @buckets[x].nil? || @buckets[x][y].nil?
      @buckets[x][y].delete item
    end
    @items.delete item
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

end

