require 'level'
require 'ftor'
require 'pretty_gem'
class DemoLevel < Level
  def setup
#    @gem = create_actor :pretty_gem
    @major_ruby = create_actor :major_ruby
    viewport.follow @major_ruby

    @stars = []
    20.times { @stars << Ftor.new(rand(viewport.width),rand(viewport.height)) }
  end

  def draw(target, x_off, y_off)
    target.fill [25,25,25,255]
    for star in @stars
      target.draw_circle_s([viewport.x_offset+star.x,viewport.y_offset+star.y],1,[255,255,255,255])
    end
  end
end

