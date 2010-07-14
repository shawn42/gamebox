require 'stage'
class DemoStage < Stage
  def setup
    super
    @my_actor = create_actor :my_actor, :x => 10, :y => 10
  end

  def draw(target)
    target.fill_screen [25,25,25,255]
    super
  end
end

