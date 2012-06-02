class DemoStage < Stage
  def setup
    super
    @player = spawn :player, x: 10, y:30
  end
end

