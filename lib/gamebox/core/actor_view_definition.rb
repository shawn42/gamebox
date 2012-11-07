class ActorViewDefinition
  attr_accessor :draw_block, :configure_block, :required_injections, :helpers_block
  def requires(*injections_needed)
    @required_injections = injections_needed
  end

  def configure(&configure_block)
    @configure_block = configure_block
  end

  def draw(&draw_block)
    @draw_block = draw_block
  end

  def helpers(&helper_block)
    @helpers_block = helper_block
  end
end

