require 'stage'
class IntroStage < Stage
  def curtain_up
    # TODO change to use actor
    @image = @resource_manager.load_image 'intro.png'
    i = @input_manager
    i.reg KeyPressed, :space do
      fire :next_stage
    end

    i.reg MousePressed do
      fire :next_stage
    end
  end

  def curtain_down(*args)
    fire :remove_me
  end

  def draw(target)
    @image.blit target.screen, [0,0] if @image
  end
end
