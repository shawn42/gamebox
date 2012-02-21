
class DemoStage < Stage
  def initialize
    super
    @my_actor = spawn :my_actor, :x => 100, :y => 100
    spawn :my_other_actor

    sound_manager.play_music :go
  end

#  def draw(target)
#    super
#  end
end

