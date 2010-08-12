require 'stage'
class IntroStage < Stage
  def curtain_up
    # TODO change to use actor
    @image = @resource_manager.load_image 'intro.png'
    i = @input_manager
    i.reg :keyboard_down, KbSpace do
      fire :next_stage
    end

    i.reg :mouse_down do
      fire :next_stage
    end
  end

  def curtain_down(*args)
    fire :remove_me
  end

  def draw(target)
    @image.draw 0, 0, 1 if @image
  end
end
