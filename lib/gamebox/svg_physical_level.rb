require 'physical_level'
require 'svg_document'

# SvgPhysicalLevel is a physical level that loads from an svg file
class SvgPhysicalLevel < PhysicalLevel
  
  def initialize(actor_factory, resource_manager, sound_manager, viewport, opts={}) 
    @actor_factory = actor_factory
    @director = PhysicalDirector.new
    @actor_factory.director = @director

    @resource_manager = resource_manager
    @sound_manager = sound_manager
    @viewport = viewport
    @opts = opts

    @space = Space.new
    @space.iterations = 20
    @space.elastic_iterations = 0

    @svg_doc = @resource_manager.load_svg @opts[:file]
    
    setup
  end
end