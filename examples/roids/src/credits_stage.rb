
class CreditsStage < Stage
  def curtain_up
    @image = @resource_manager.load_image 'credits.png'
    i = @input_manager
    i.reg :down, KbSpace do
      fire :next_stage
    end
  end

  def curtain_down(*args)
    # TODO change to use actor
    fire :remove_me
  end

  def draw(target)
    @image.draw 0,0,1 if @image
  end
end
