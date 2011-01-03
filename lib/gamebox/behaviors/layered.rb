
# Keeps track of the layer that something is to be drawn on.
# By default it sets everything to layer 0 and parallax layer of
# 1.
class Layered < Behavior

  attr_accessor :layer, :parallax
  def setup
    if @opts.is_a? Hash
      @layer = @opts[:layer]
      @parallax = @opts[:parallax]
    else
      @layer = @opts
    end
    
    @layer ||= 0
    @parallax ||= 1

    relegates :layer=, :layer, :parallax=, :parallax, 
      :layered
  end

  def layered
    self
  end

  def parallax=(new_parallax)
    @parallax = new_parallax
  end

  def layer=(new_layer)
    @layer = new_layer
  end
end
