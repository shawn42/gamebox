require 'actor'
require 'two_d_grid_map'

class Mappy < Actor
  attr_reader :major_ruby

  def setup
    load_map @opts[:map_filename]
  end

  def load_map(filename)
    lines = File.readlines(File.join(DATA_PATH,"maps",filename)).map { |line| line.chop }
    @height = lines.size
    @width = lines[0].size

    @map = TwoDGridMap.new @width, @height
    tw = 60
    th = 60

    @width.times do |x|
      @height.times do |y|
        type = 
          case lines[y][x, 1]
            when '"'
              # grass
              :grass
              :pretty_gem
            when '#'
              # earth
              :earth
              :pretty_gem
            when 'x'
              # gem
              :pretty_gem
            else
              nil
          end
        unless type.nil?
          # no overlap yet
          thing = spawn type, :x => x*tw, :y => y*tw
          @map.place(TwoDGridLocation.new(x,y), thing)
        end
      end
    end

    @major_ruby = spawn :major_ruby, :x => 400, :y => 100
  end
  
end
