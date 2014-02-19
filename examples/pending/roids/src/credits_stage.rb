define_stage :credits do
  curtain_up do
    create_actor :icon, image: 'credits.png', x: viewport.width / 2, y: viewport.height / 2
    timer_manager.add_timer "exit", 3000 do
      input_manager.reg :down, KbSpace do
        fire :change_stage, :intro
      end
    end
  end

  curtain_down do
    fire :remove_me
  end

  helpers do
  end
end
