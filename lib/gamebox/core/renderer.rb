class Renderer
  construct_with :viewport

  def initialize
    clear_drawables
  end

  def register_drawable(drawable)
    layer = drawable.layer
    parallax = drawable.parallax
    unless @drawables[parallax]
      @drawables[parallax] = {}
      @parallax_layers = @drawables.keys.sort.reverse
    end
    unless @drawables[parallax][layer]
      @drawables[parallax][layer] = []
      @layer_orders[parallax] = @drawables[parallax].keys.sort
    end
    @drawables[parallax][layer] << drawable
  end


  def unregister_drawable(drawable)
    @drawables[drawable.parallax][drawable.layer].delete drawable
  end

  def clear_drawables
    @drawables = {}
    @layer_orders = {}
    @parallax_layers = []
  end


  def draw(target)
    center_x = viewport.width / 2
    center_y = viewport.height / 2

    target.rotate(-viewport.rotation, center_x, center_y) do
      z = 0
      @parallax_layers.each do |parallax_layer|
        drawables_on_parallax_layer = @drawables[parallax_layer]

        if drawables_on_parallax_layer
          @layer_orders[parallax_layer].each do |layer|

            trans_x = viewport.x_offset parallax_layer
            trans_y = viewport.y_offset parallax_layer

            z += 1
            drawables_on_parallax_layer[layer].each do |drawable|
              drawable.draw target, trans_x, trans_y, z
            end
          end
        end
      end
    end
  end

  # move all actors from one layer to another
  # note, this will remove all actors in that layer!
  def move_layer(from_parallax, from_layer, to_parallax, to_layer)
    drawable_list = @drawables[from_parallax][from_layer].dup

    drawable_list.each do |drawable|
      unregister_drawable drawable      
      drawable.parallax = to_parallax
      drawable.layer = to_layer
      register_drawable drawable      
    end
  end

end
