class LinkedList
  include Enumerable

  ListElem = Struct.new(:obj, :prev, :next)
  attr_accessor :head, :tail

  def initialize(enum = nil)
    @head = @tail = ListElem.new
    @head.next = @head
    @head.prev = @head

    append enum unless enum.nil?
  end

  # pop off the first item
  def shift
    tmp = @head.next
    @head.next = tmp.next
    tmp.next.prev = @head
    #puts "SHIFTING [#{tmp.obj.x},#{tmp.obj.y}]"
#    puts to_s
    return tmp.obj
  end

  # pop off the last item
  def unshift
    tmp = @tail.prev
    @tail.prev = @tail.prev.prev
    @tail.next = @tail
    return tmp.obj
  end

  def place(new_obj, location, elem)
#    puts "placing #{new_obj[0][0]},#{new_obj[0][1]} #{location} #{elem.obj[0][0]},#{elem.obj[0][1]}"
    tmp = ListElem.new
    tmp.obj = new_obj
    case location
    when :before
      tmp.next = elem
      tmp.prev = elem.prev
      elem.prev.next = tmp
      elem.prev = tmp
    when :after
      tmp.prev = elem
      tmp.next = elem.next
      elem.next.prev = tmp
      elem.next = tmp
    end
#    puts to_s
    tmp
  end

  def append(e)
#    puts "appending #{e[0][0]},#{e[0][1]}"
    tmp = ListElem.new
    tmp.obj = e
    tmp.prev = @tail.prev
    tmp.next = @tail
    tmp.prev.next = tmp
    tmp.next.prev = tmp
#    puts to_s
    self
  end

  alias :<< :append
  def prepend(e)
    tmp = ListElem.new
    tmp.obj = e
    tmp.prev = @head
    tmp.next = @head.next
    tmp.prev.next = tmp
    tmp.next.prev = tmp
    self
  end
  alias :>> :prepend

  # only removed the first instance of e
  def remove(e)
    i = @head.next

    while @tail != i
      if i.obj == e
        # remove it
        i.prev.next = i.next
        i.next.prev = i.prev
        return i.obj
      end
      i = i.next
    end
    i
  end
  alias :- :remove

  def empty?()
    @tail.prev == @head
  end

  def each
    i = @head.next

    while @tail != i
      yield i.obj
      i = i.next
    end
  end

  def each_element
    i = @head.next

    while @tail != i
      yield i
      i = i.next
    end
  end

  def to_s
    str = "LinkedList #{self.object_id} ["
    i = @head.next

    while @tail != i
      str += "#{i.obj[0]}-#{i.obj[1]},"
      i = i.next
    end
    str  += "]"
    str
  end

  def size
    size = 0
    i = @head.next
    while @tail != i
      i = i.next
      size += 1
    end
    size
  end
end 
