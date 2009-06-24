require 'actor'

class Rague < Actor
  has_behaviors :graphical, :updatable, :layered => 3
  
  attr_accessor :stats, :tile_x, :tile_y

  def setup
    
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
      puts "picked up #{thing.class}"
    end
  end
  
  def generate_random_stats
    @stats = {
      :strength=>57,
      :intelligence=>44,
      :constitution=>71,
      :dexterity=>58
    }
  end
  
end
