class Stagehand
  attr_accessor :opts, :stage
  def initialize(stage, opts)
    @stage = stage
    @opts = opts
    setup
  end

  def setup
  end
end
