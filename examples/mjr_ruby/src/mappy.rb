require 'actor'
require 'two_d_grid_map'
require 'actor_view'

class FogView < ActorView
  def draw(target, x_off, y_off)
    target.screen.draw_box_s [0,0],[1024,800],[120,120,120,120]
  end
end
class Fog < Actor
  has_behavior :layered
end
class Mappy < Actor
  attr_reader :major_ruby, :tw, :th, :width, :height, :actors

  def setup
    @maps = []
    @pretty_gems = []
    @actors = []
    @z = 0
    filenames = @opts[:map_filenames].split ','
    filenames.each_with_index do |fn,i|
      @maps << load_map(fn,i)
    end

    @fog = spawn :fog
    self.z_level=0

    @major_ruby = spawn :major_ruby, :x => 400, :y => 100, :map => self
    input_manager.reg KeyDownEvent, :space do
      rotate_layers
    end
  end

  def finished?
    @pretty_gems.inject(0){|first,second|first + second.size} == 0
  end

  def rotate_layers
    new_z = (@z + 1) % @actors.size
    self.z_level = new_z
  end

  def remove(gems)
    @actors[@z].delete_if{|it|gems.include? it}
    @pretty_gems[@z].delete_if{|it|gems.include? it}
  end

  def z_level=(new_z)
    
    if @actors[@z]
      @actors[@z].each do |a|
        a.layer = @z+1
      end
    end

    @fog.layer = @z+2
    @z = new_z

    if @actors[@z]
      @actors[@z].each do |a|
        a.layer = @z+3
      end
    end
    self.pretty_gems.each { |pg| pg.layer=@z+4 }
  end

  def pretty_gems
    @pretty_gems[@z]
  end

  def load_map(filename, z)
    lines = File.readlines(File.join(DATA_PATH,"maps",filename)).map { |line| line.chop }
    @height = lines.size
    @width = lines[0].size
    @pretty_gems[z] ||= []
    @actors[z] ||= []
    @tw = 44
    @th = 44


    map = TwoDGridMap.new @width, @height

    @width.times do |x|
      @height.times do |y|
        type = 
          case lines[y][x, 1]
            when '"'
              # grass
              :grass
            when '#'
              # earth
              :earth
            when 'x'
              # gem
              :pretty_gem
            else
              nil
          end
        unless type.nil?
          # no overlap yet
          thing = spawn type, :x => x*@tw, :y => y*@tw
          @actors[z] << thing
          thing.layer = 1
#          thing.hide
          @pretty_gems[z] << thing if type == :pretty_gem
          map.place(TwoDGridLocation.new(x,y), thing)
        end
      end
    end

    map
  end

  def solid?(x,y)
    occ = @maps[@z].occupant TwoDGridLocation.new(x/@tw, y/@th)
    not occ.nil? and occ.class != PrettyGem
  end
  
end
