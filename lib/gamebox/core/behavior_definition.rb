class BehaviorDefinition
  attr_accessor :setup_block, :required_injections, :react_to_block, :required_behaviors,
    :helpers_block, :source

  def requires(*injections_needed)
    @required_injections = injections_needed
  end

  def requires_behaviors(*behaviors_needed)
    @required_behaviors = behaviors_needed
  end

  def setup(&setup_block)
    @setup_block = setup_block
  end

  def react_to(&react_to_block)
    @react_to_block = react_to_block
  end

  def helpers(&helpers_block)
    @helpers_block = helpers_block
  end
end
