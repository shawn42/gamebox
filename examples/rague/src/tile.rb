  
define_behavior :map_tile do

  setup do
    actor.has_attributes animating: false,
                         action: :floor
    
    actor.has_attributes tile_x: 0,
                         tile_y: 0,
                         tile_width: 30,
                         tile_height: 30,
                         lit: false,
                         seen: false,
                         solid: false

    actor.has_attributes location: loc2(actor.tile_x, actor.tile_y),
                         occupants: []

    actor.when :lit_changed do
      update_occupant_visiblity
    end
  end

  helpers do 
    
    def update_occupant_visiblity

      actor.occupants.each do |occ|
        if actor.lit
          occ.react_to :show
        else
          occ.react_to :hide
        end
      end
    end
    
  end
end

# Tile is a location on the map
define_actor :tile do
  has_behaviors :map_tile, :animated

  view do
    draw do |target, x_off, y_off, z|
      w = actor.tile_width
      h = actor.tile_height
      x = actor.x+x_off
      y = actor.y+y_off
      
      if actor.seen? || actor.lit?  
        img = actor.do_or_do_not(:image)
        return if img.nil?

        alpha = actor.do_or_do_not(:alpha) || 0xFF
        color = Color.new(alpha,0xFF,0xFF,0xFF)

        x_scale = actor.do_or_do_not(:x_scale) || 1
        y_scale = actor.do_or_do_not(:y_scale) || 1

        img.draw x, y, z, x_scale, y_scale, color
      end

      alpha = 255
      alpha -= 155 if actor.seen?
      alpha = 0 if actor.lit?
    
      color = [0,0,0,alpha]
      target.fill(x,y,x+w-1,y+h-1, color, z)
    end
  end
end

# helper for creating locations more easily
def loc2(x,y)
  TwoDGridLocation.new x, y
end
