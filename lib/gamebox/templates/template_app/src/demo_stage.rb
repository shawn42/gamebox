
class DemoStage < Stage
  def setup
    super
    @my_actor = create_actor :my_actor, :x => 10, :y => 10
  end

  def draw(target)
    super
  end
end

