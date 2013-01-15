class StageDefinition
  attr_accessor :curtain_up_block, :curtain_down_block, :renderer,
    :helpers_block, :required_injections, :source

  # Required objects that you need for your specific stage
  # The objects will be created for you.
  # example:
  # define_stage :main_menu do
  #   require :magic_thinger
  # end
  def requires(*injections_needed)
    # kid.construct_with *self.object_definition.component_names
    @required_injections = injections_needed
  end

  # Define a block of code to run when your stage is and ready to play
  # example:
  # define_stage :main_menu do
  #   curtain_up do
  #     @info = load_some_info
  #   end
  # end
  def curtain_up(&curtain_up_block)
    @curtain_up_block = curtain_up_block
  end

  # Define a block of code to run when your stage has been shutdown
  # example:
  # define_stage :main_menu do
  #   curtain_down do
  #     @info = load_some_info
  #   end
  # end
  def curtain_down(&curtain_down_block)
    @curtain_down_block = curtain_down_block
  end

  # Replaces the default renderer with your own.
  # example:
  #   define_stage :main_menu do
  #     render_with :my_render
  #     ...
  #   end
  def render_with(render_class_name)
    @renderer = render_class_name
  end

  # Define any helper methods / include modules here
  # These will be available for curtain_up / update / draw to use.
  # example:
  # define_stage :main_menu do
  #   include MinMaxHelpers
  #   def calculate_thinger
  #     ...
  #   end
  # end
  def helpers(&helpers_block)
    @helpers_block = helpers_block
  end
end
