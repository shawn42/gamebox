require 'actor'

class Rague < Actor
  has_behaviors :graphical, :updatable, :layered => 3
  
  attr_accessor :stats, :tile_x, :tile_y, :inventory

  def setup
    @inventory = []
    generate_random_stats

    i = input_manager
    i.reg KeyDownEvent, K_RIGHT do
      fire :move_right
    end
    i.reg KeyDownEvent, K_LEFT do
      fire :move_left
    end
    i.reg KeyDownEvent, K_UP do
      fire :move_up
    end
    i.reg KeyDownEvent, K_DOWN do
      fire :move_down
    end
    
    i.reg KeyDownEvent, K_SPACE do
      # skip turn
      fire :action_taken
    end
    
    i.reg KeyDownEvent, K_C do
      puts "clearing inventory"
      @inventory.each do |i|
        remove_from_inventory i
      end
    end
  end

  # allows for rague to handle the contents of the given tile
  def handle_tile_contents(tile)
    removed = []
    tile.occupants.each do |thing|
      # TODO actually do something here...
      if thing.is? :hostile
        # TODO fight it?
      elsif thing.is? :pickupable
        # pick it up?
        removed << thing
      else
        # nothing?
      end
    end
    removed.each do |thing|
      tile.occupants.delete thing
      thing.hide
      thing.remove_self
      
      add_to_inventory thing
    end
  end
  
  def add_to_inventory(item)
    puts "picked up #{item.class}"
    
    # TODO only apply if item is equipped in its slot
    item.apply_stats self if item.is? :stat_modifier
    p @stats
    @inventory << item
  end
  
  def remove_from_inventory(item)
    puts "removed #{item.class}"
    
    # TODO only remove if item is unequipped from its slot
    item.remove_stats self if item.is? :stat_modifier
    p @stats
    @inventory.delete item
  end
  
  def generate_random_stats
    @stats = {
      :strength=>40+rand(50),
      :intelligence=>40+rand(50),
      :constitution=>40+rand(50),
      :dexterity=>40+rand(50)
    }
    p @stats
  end
  
end
