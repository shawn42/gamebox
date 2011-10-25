


class SpatialDebugger < Actor
  
  has_behavior :updatable

  attr_reader :spatial, :ratio
  def setup
    @spatial = stage.stagehand(:spatial)
  end

  def update(time)
    super
    if stage.checks && stage.checks > 0
      @ratio = "size:#{@spatial.cell_size} #{stage.collisions} / #{stage.checks} ("
      @ratio += "#{stage.collisions / stage.checks.to_f})"
    else
      @ratio = "N/A"
    end
  end
  
end

class SpatialDebuggerView < ActorView
  def setup
    # size = 30
    # font = "Asimov.ttf"
    # @font = @actor.resource_manager.load_font font, size
  end

  def draw(target,x_off,y_off, z)
    vp = stage.viewport
    cell_size = @actor.spatial.cell_size
    max = 0
    @actor.spatial.buckets.each do |x_bucket,stuff|
      stuff.each do |y_bucket,items|
        # max = items.size if items.size > max
        x = x_bucket * cell_size + x_off
        y = y_bucket * cell_size + y_off
        target.draw_box x, y, x+cell_size, y+cell_size, [255,25,25], z

        # Yes I know I may be drawing this many times for an actor
        items.each do |item|
          # puts "#{item.class}: [#{item.center_x}, #{item.center_y}] #{item.collidable_shape}"
          parallax = 1
          ix = item.center_x + x_off
          iy = item.center_y + y_off

          target.draw_box ix, iy, ix + 2, iy + 2, [255,255,255], 10

          # TODO make work for non circles
          r = item.radius
          target.draw_box ix-r, iy-r, ix + r, iy + r, [255,255,255], 10
        end
      end
    end

    # @text_image = @font.render "#{@actor.ratio} [#{max}]", true, Color[:white]
    # @text_image.blit target.screen, [@actor.x, @actor.y]
  end
end
