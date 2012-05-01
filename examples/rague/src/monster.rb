define_actor :monster do
  has_behaviors :mapped, :monstery, :animated, layered: 2
end

define_behavior :monstery do
  setup do
    actor.has_attributes action: actor.name
    # 
    # # TODO pull this into external file
    # @hard_coded = {}
    # goblin_def = {}
    # behaviors = []
    # behaviors << :wanderer
    # goblin_def[:behaviors] = behaviors
    # @hard_coded[:goblin] = goblin_def
    # 
    # monster_def = @hard_coded[name]
    # unless monster_def.nil?
    #   monster_def[:behaviors].each do |b|
    #     is b
    #   end
    # end
    # is_no_longer :updatable
    reacts_with :move_up, :move_down, :move_left, :move_right
  end

  helpers do
    
    def move_up
      actor.emit :move_up
    end
    
    def move_down
      actor.emit :move_down
    end
    
    def move_left
      actor.emit :move_left
    end
    
    def move_right
      actor.emit :move_right
    end
  end

end
