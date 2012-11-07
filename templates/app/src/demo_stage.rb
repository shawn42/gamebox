define_stage :demo do
  # render_with :renderer
  render_with :my_renderer

  setup do
    @player = spawn :player, x: 10, y:30
  end

  # helpers do
  #   include StageHelpers
  # end
end

# class MyRenderer
#   conject_with :viewport, :foo
#   def draw(target)
#   end
# end
