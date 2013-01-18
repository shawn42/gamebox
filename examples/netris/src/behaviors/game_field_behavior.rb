define_behavior :game_field do
  requires :director, :input_manager, :stage

  setup do
    actor.has_attributes grid: Grid.new(10, 21),
                         drop_after: 500,
                         time_lapsed: 0

    actor.grid.when(:game_over) do
      puts "Game over man!"
      # TODO nice way to quit a game, or
      # a menu system so we jump back into the menu stage
      exit(0)
    end

    actor.grid.when(:next_level) do
      puts "Next Level!"
      actor.drop_after -= 50
    end

    # Setup our key events into the grid
    input_manager.reg :down, KbN do
      actor.grid.start_play(actor, stage)
    end

    input_manager.reg :down, KbSpace do
      actor.grid.drop_piece
    end

    input_manager.reg :down, KbLeft do
      actor.grid.piece_left
    end

    input_manager.reg :down, KbRight do
      actor.grid.piece_right
    end

    input_manager.reg :down, KbDown do
      actor.grid.piece_down
    end

    input_manager.reg :down, KbUp do
      actor.grid.rotate_piece
    end

    director.when :update do |time|
      if actor.grid.playing?
        actor.time_lapsed += time

        if actor.time_lapsed >= actor.drop_after
          actor.grid.piece_down
          actor.time_lapsed = 0
        end
      end
    end
  end

  helpers do

  end
end
