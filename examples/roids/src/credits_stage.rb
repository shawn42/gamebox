define_stage :credits do
  helpers do
    def curtain_up
      create_actor :icon, image: 'credits.png', x: viewport.width / 2, y: viewport.height / 2
      timer_manager.add_timer "exit", 3000 do
        input_manager.reg :down, KbSpace do
          exit
        end
      end
    end

    def curtain_down(*args)
      fire :remove_me
    end
  end
end
