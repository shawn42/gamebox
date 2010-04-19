require 'stage'
class CreditsStage < Stage
  def curtain_up
    @image = @resource_manager.load_image 'credits.png'
    i = @input_manager
    i.reg KeyPressed, :space do
      fire :next_stage
    end
  end

  def curtain_down(*args)
    # TODO change to use actor
    fire :remove_me
  end

  def draw(target)
    @image.blit target.screen, [0,0] if @image
  end
end
