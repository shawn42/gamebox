class ActorViewDefinition
  attr_accessor :draw_block, :setup_block, :required_injections, :helpers_block, :source

  # Sets the dependencies for this ActorView.
  #
  # These will be pulled from the Actor's object context at view construction time.
  #
  #  requires :resource_manager
  #
  def requires(*injections_needed)
    @required_injections = injections_needed
  end

  # Setup callback that is called when the view is constructed. The actor will
  # be set before your setup block is executed.
  #
  #  setup do
  #    resource_manager.load_image('something.png')
  #  end
  #  
  def setup(&setup_block)
    @setup_block = setup_block
  end

  # Draw callback that is called when the view needs to draw.
  # 
  #  draw do |screen, x_offset, y_offset, z|
  #    ...
  #  end
  #
  def draw(&draw_block)
    @draw_block = draw_block
  end

  # Define methods and include modules for use by your view.
  #  helpers do
  #    include MyHelper
  #    def do_some_view_calc
  #      ...
  #    end
  #  end
  #  
  def helpers(&helper_block)
    @helpers_block = helper_block
  end
end

