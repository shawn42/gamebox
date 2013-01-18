define_stage :demo do
  curtain_up do
    sound_manager.play_music :current_rider
    @game_field = create_actor :game_field, x: 50, y: 80
    create_actor :label,
                 text: "Press N to start a new game",
                 x: 100,
                 y: 10,
                 font_name: "Asimov.ttf",
                 font_size: 30,
                 color: [250, 250, 250, 255]
  end
end
