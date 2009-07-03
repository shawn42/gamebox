require 'helper'
require 'ai/line_of_site'
require 'ai/two_d_grid_map'

describe 'A new LineOfSite' do
  before do
    @map = TwoDGridMap.new 10, 20
    @los = LineOfSite.new @map
  end

  it 'should be sane'
end
