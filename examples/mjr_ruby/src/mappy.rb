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

  LAYER_OFFSET = 3

  def setup
    @maps = []
    @pretty_gems = []
    @actors = []
    @z = 1
    filenames = @opts[:map_filenames].split ','
    filenames.each_with_index do |fn,i|
      @maps << load_map(fn,i)
    end

    @fog = spawn :fog, :visible => false
    @fog.layer = 1000#@actors.size*LAYER_OFFSET-1
    @fog.show
#    @z = 1
#    self.z_level=0

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
    fire :move_layer, 1, @actors.size*LAYER_OFFSET, 1, 900

    @z = new_z

    fire :move_layer, 1, @z*LAYER_OFFSET, 1, @actors.size*LAYER_OFFSET
    fire :move_layer, 1, 900, 1, @z*LAYER_OFFSET
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
          thing = spawn type, :x => x*@tw, :y => y*@tw, :visible=>false
          @actors[z] << thing
          thing.layer = z*LAYER_OFFSET
          thing.show

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
