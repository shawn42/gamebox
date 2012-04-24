
# Keeps track of the layer that something is to be drawn on.
# By default it sets everything to layer 0 and parallax layer of
# 1.
Behavior.define :layered do

  setup do
    if @opts.is_a? Hash
      layer = @opts[:layer]
      parallax = @opts[:parallax]
    else
      layer = @opts
    end
    
    layer ||= 0
    parallax ||= 1

    actor.has_attributes layer: layer, parallax: parallax
  end

end
