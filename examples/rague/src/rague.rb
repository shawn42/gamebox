define_actor :rague do
  has_behaviors :mapped, :rague_like, :graphical, layered: 3
end

define_behavior :rague_like do

  requires :input_manager
  setup do
    generate_random_stats
    actor.has_attributes stats: generate_random_stats, 
                         inventory: []


    i = input_manager
    i.reg :down, KbRight do
      actor.emit :move_right
    end
    i.reg :down, KbLeft do
      actor.emit :move_left
    end
    i.reg :down, KbUp do
      actor.emit :move_up
    end
    i.reg :down, KbDown do
      actor.emit :move_down
    end
    
    i.reg :down, KbSpace do
      # skip turn
      actor.emit :action_taken
    end
    
    i.reg :down, KbC do
      puts "clearing inventory"
      actor.inventory.each do |i|
        remove_from_inventory i
      end
    end

    reacts_with :handle_tile_contents
  end

  helpers do

    # allows for rague to handle the contents of the given tile
    def handle_tile_contents(tile)
      removed = []
      tile.occupants.each do |thing|
        # TODO actually do something here...
        # EEEWWWWW
        if thing.do_or_do_not :hostile
          # TODO fight it?
        elsif thing.do_or_do_not :pickupable
          # pick it up?
          removed << thing
        else
          # nothing?
        end
      end
      removed.each do |thing|
        tile.occupants.delete thing
        thing.react_to :hide
        thing.remove
        
        add_to_inventory thing
      end
    end
    
    def add_to_inventory(item)
      puts "picked up #{item.class}"
      
      # TODO only apply if item is equipped in its slot
      item.apply_stats actor if item.is? :stat_modifier
      puts actor.stats.inspect
      actor.inventory << item
    end
    
    def remove_from_inventory(item)
      puts "removed #{item.class}"
      
      # TODO only remove if item is unequipped from its slot
      item.remove_stats actor if item.is? :stat_modifier
      puts actor.stats.inspect
      actor.inventory.delete item
    end
    
    def generate_random_stats
      {
        :strength=>40+rand(50),
        :intelligence=>40+rand(50),
        :constitution=>40+rand(50),
        :dexterity=>40+rand(50)
      }.tap do |stats|
        p stats
      end
    end
  end
end
