

define_actor :item do
  has_behaviors :mapped, :item_like, :animated, layered: 2
end

define_behavior :item_like do
  setup do
    actor.has_attributes action: actor.name
    
    # TODO pull this into external file
    # @hard_coded = {}
    # sword_def = {}
    # behaviors = []
    # behaviors << :pickupable
    # behaviors << {:stat_modifier => {:strength=>20}}
    # sword_def[:behaviors] = behaviors
    # sword_def[:slot] = :weapon
    # @hard_coded[:sword] = sword_def
    # 
    # item_def = @hard_coded[name]
    # unless item_def.nil?
    #   item_def[:behaviors].each do |b|
    #     is b
    #   end
    # end
  end

end
