require 'linked_list'

# Keeps a list of items sorted. Elements must be comparable
class SortedList
  attr_reader :list
  def initialize(initial_list=nil)
    @list = LinkedList.new
    unless initial_list.nil?
      initial_list.each do |item|
        add item
      end
    end
  end
  
  def add(item)
    added = false
    @list.each_element do |node|
      if node.obj > item
        added = true
        @list.place item, :before, node
        break
      end
    end
    @list << item unless added
    item
  end
  alias :<< :add
  
  def shift
    @list.shift
  end
  
  def empty?
    @list.empty?
  end
  
  def contains?(item)
    @list.each do |obj|
      if obj == item
        return true
      end
    end
    false
  end
  
  def find(item)
    @list.each do |obj|
      if obj == item
        return obj
      end
    end
    nil
  end
  
  def size
    @list.size
  end
  
end