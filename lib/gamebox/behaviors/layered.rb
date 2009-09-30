require 'behavior'
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

    layered_obj = self
    @actor.instance_eval do
      (class << self; self; end).class_eval do
        define_method :layer= do |new_layer|
          layered_obj.layer = new_layer
        end
        define_method :parallax= do |new_parallax|
          layered_obj.parallax = new_parallax
        end
        define_method :layer do 
          layered_obj.layer
        end
        define_method :parallax do 
          layered_obj.parallax
        end
        define_method :layered do 
          layered_obj
        end
      end
    end
  end

  def parallax=(new_parallax)
    @parallax = new_parallax
  end

  def layer=(new_layer)
    @layer = new_layer
  end
end
