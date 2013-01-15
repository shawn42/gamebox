class ActorViewDefinition
  attr_accessor :draw_block, :setup_block, :required_injections, :helpers_block, :source
  def requires(*injections_needed)
    @required_injections = injections_needed
  end

  def setup(&setup_block)
    @setup_block = setup_block
  end

  def draw(&draw_block)
    @draw_block = draw_block
  end

  def helpers(&helper_block)
    @helpers_block = helper_block
  end
end

