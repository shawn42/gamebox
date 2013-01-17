define_stage :demo do
  # render_with :my_renderer

  curtain_up do
    @player = spawn :player, x: 10, y:30
  end

  # helpers do
  #   include MyHelpers
  #   def help
  #     ...
  #   end
  # end
end
