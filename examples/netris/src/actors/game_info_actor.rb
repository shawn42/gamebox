define_actor :game_info do
  has_behavior :positioned
  has_attributes  current_level: 0,
                  score: 0,
                  level_actor: nil,
                  score_actor: nil

  view do
    requires :stage
    draw do |target, x_off, y_off, z|
      actor.level_actor.text = "Level #{actor.current_level}"
      actor.score_actor.text = "#{actor.score}"
    end

    setup do
      actor.level_actor = stage.create_actor(:label, text: "", x: actor.x, y: actor.y, font_name: "Asimov.ttf", font_size: 30, color: [250, 250, 250, 255])
      actor.score_actor = stage.create_actor(:label, text: "", x: actor.x, y: actor.y+40, font_name: "Asimov.ttf", font_size: 30, color: [250, 250, 250, 255])
    end
  end
end
