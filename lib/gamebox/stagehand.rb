class Stagehand
  attr_accessor :opts
  def initialize(stage, opts)
    @opts = opts
    setup
  end

  def setup
  end
end
