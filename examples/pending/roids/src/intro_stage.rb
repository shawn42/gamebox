define_stage :intro do

  curtain_up do
    create_actor :icon, image: 'intro.png', x: viewport.width / 2, y: viewport.height / 2
    input_manager.reg :down, KbSpace do
      fire :next_stage
    end

    input_manager.reg :mouse_down do
      fire :next_stage
    end
  end

  curtain_down do
    fire :remove_me
  end

  helpers do
  end

end
