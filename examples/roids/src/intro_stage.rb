define_stage :intro do

  helpers do
    def curtain_up
      create_actor :icon, image: 'intro.png', x: viewport.width / 2, y: viewport.height / 2
      input_manager.reg :down, KbSpace do
        fire :next_stage
      end

      input_manager.reg :mouse_down do
        fire :next_stage
      end
    end

    def curtain_down(*args)
      fire :remove_me
    end
  end
end
