require 'physical_level'
class DemoLevel < PhysicalLevel
  def setup
    ship = @actor_factory.build :ship, self
    ship.warp vec2(300,300)

    dir = Director.new
    @directors << dir
    dir.actors << ship

    left_wall = @actor_factory.build :left_wall, self,
      :view => WallView
    top_wall = @actor_factory.build :top_wall, self,
      :view => WallView
    right_wall = @actor_factory.build :right_wall, self,
      :view => WallView
    bottom_wall = @actor_factory.build :bottom_wall, self,
      :view => WallView

    right_wall.warp vec2(1023,0)
    bottom_wall.warp vec2(0,799)

    # TODO get this from screen config
    @width = 1024
    @height = 800
    @space.add_collision_func(:ship, :left_wall) do |ship, wall|
      bb = ship.bb
      ship.body.p = vec2(@width-bb.r-bb.l,ship.body.p.y)
    end
    @space.add_collision_func(:ship, :right_wall) do |ship, wall|
      bb = ship.bb
      ship.body.p = vec2(bb.r-bb.l,ship.body.p.y)
    end
    @space.add_collision_func(:ship, :top_wall) do |ship, wall|
      bb = ship.bb
      ship.body.p = vec2(ship.body.p.x,@height-bb.b-bb.t)
    end
    @space.add_collision_func(:ship, :bottom_wall) do |ship, wall|
      bb = ship.bb
      ship.body.p = vec2(ship.body.p.x,bb.t-bb.b)
    end
  end
end

