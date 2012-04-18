
# keeps track of an image for you based on the actor's class
# by default it expects images to be:
# data/graphics/classname.png
Behavior.define :graphical do

  requires :resource_manager
  setup do 
    image = resource_manager.load_actor_image(actor)
    scale = @opts[:scale] || 1,
    actor.has_attributes( image: image,
                          width: image.width,
                          height: image.height,
                          tiled: @opts[:tiled],
                          num_x_tiles: @opts[:num_x_tiles] || 1,
                          num_y_tiles: @opts[:num_y_tiles] || 1,
                          scale: scale,
                          x_scale: @opts[:x_scale] || scale,
                          y_scale: @opts[:y_scale] || scale,
                          rotation: 0.0 )

    actor.when :image_changed do |old, new|
      actor.width = new.width
      actor.height = new.height
    end
  end

end
