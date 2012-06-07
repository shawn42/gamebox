require 'helper'

class Arb
  include Arbiter
end

describe 'Arbiter' do

  before do
    @arbiter = Arb.new
  end

  it 'should construct' do
    @arbiter.should_not be_nil
  end

  describe '#collide?' do
    it 'should call the correct circle circle collision method' do
      a = stub(:shape_type => :circle)
      b = stub(:shape_type => :circle)
      @arbiter.expects(:collide_circle_circle?).with(a,b).returns(true)

      @arbiter.collide?(a,b).should be_true
    end

    it 'should call the correct circle polygon collision method' do
      a = stub(:shape_type => :circle)
      b = stub(:shape_type => :polygon)
      @arbiter.expects(:collide_circle_polygon?).with(a,b).returns(true)

      @arbiter.collide?(a,b).should be_true
    end

    it 'should call the correct polygon circle collision method' do
      a = stub(:shape_type => :polygon)
      b = stub(:shape_type => :circle)
      @arbiter.expects(:collide_circle_polygon?).with(b,a).returns(true)

      @arbiter.collide?(a,b).should be_true
    end
  end

  describe '#collide_circle_circle?' do
    it 'should collide overlapping circles' do
      a = stub(:center_x => 0, :center_y => 0, :radius => 30, :shape_type => :circle)
      b = stub(:center_x => 0, :center_y => 10, :radius => 3, :shape_type => :circle)
      @arbiter.collide_circle_circle?(a, b).should be_true
    end

    it 'should collide a circle in a circle' do
      a = stub(:center_x => 0, :center_y => 0, :radius => 30, :shape_type => :circle)
      b = stub(:center_x => 10, :center_y => 10, :radius => 30, :shape_type => :circle)
      @arbiter.collide_circle_circle?(a, b).should be_true
    end

    it 'should not collide non-overlapping circles' do
      a = stub(:center_x => 0, :center_y => 0, :radius => 30, :shape_type => :circle)
      b = stub(:center_x => 100, :center_y => 100, :radius => 30, :shape_type => :circle)
      @arbiter.collide_circle_circle?(a, b).should be_false
    end
  end

  describe '#collide_polygon_polygon?' do
    it 'should not collide non-overlapping polys based on radius' do
      a = stub(:center_x => 0, :center_y => 0, :radius => 30, :shape_type => :polygon)
      b = stub(:center_x => 61, :center_y => 0, :radius => 30, :shape_type => :polygon)
      @arbiter.collide_polygon_polygon?(a,b).should be_false
    end

    it 'should not collide non-overlapping polys based on points' do
      a = stub(:center_x => 0, :center_y => 0, :radius => 30, :shape_type => :polygon,
               :cw_world_points => [
                 [0,0],[0,30], [0,30]
               ],
               :cw_world_lines => [
                 [0,0],[0,30],
                 [0,30],[30,0],
                 [30,0],[0,0]
               ],
               :cw_world_edge_normals => [
                 [-30,0],
                 [30,30],
                 [0,-30]
               ]

              )
      b = stub(:center_x => 60, :center_y => 0, :radius => 30, :shape_type => :polygon,
               :cw_world_points => [
                 [60,0],[60,30], [90,0]
               ],
               :cw_world_lines => [
                 [60,0],[60,30],
                 [60,30],[90,0],
                 [90,0],[60,0]
               ],
               :cw_world_edge_normals => [
                 [-30,0],
                 [30,30],
                 [0,-30]
               ]
              )
      @arbiter.collide_polygon_polygon?(a,b).should be_false
    end

    it 'should collide non-overlapping polys based on points' do
      a = stub(:center_x => 0, :center_y => 0, :radius => 30, :shape_type => :polygon,
               :cw_world_points => [
                 [0,0],[0,30],[30,0]
               ],
               :cw_world_lines => [
                 [0,0],[0,30],
                 [0,30],[30,0],
                 [30,0],[0,0]
               ],
               :cw_world_edge_normals => [
                 [30,0],
                 [30,30],
                 [0,-30]
               ]
              )
      b = stub(:center_x => 29, :center_y => 0, :radius => 30, :shape_type => :polygon,
               :cw_world_points => [
                 [29,0],[29,30],[59,0]
               ],
               :cw_world_lines => [
                 [29,0],[29,30],
                 [29,30],[59,0],
                 [59,0],[29,0]
               ],
               :cw_world_edge_normals => [
                 [-30,0],
                 [30,30],
                 [0,-30]
               ]
              )
      @arbiter.collide_polygon_polygon?(a,b).should be_true
    end

    it 'should collide completely overlapping polys based on points' do
      a = stub(:center_x => 0, :center_y => 0, :radius => 30, :shape_type => :polygon,
               :cw_world_points => [
                 [0,0],[0,30],[30,0]
               ],
               :cw_world_lines => [
                 [0,0],[0,30],
                 [0,30],[30,0],
                 [30,0],[0,0]
               ],
               :cw_world_edge_normals => [
                 [30,0],
                 [30,30],
                 [0,-30]
               ]
              )
      b = stub(:center_x => 2, :center_y => 0, :radius => 10, :shape_type => :polygon,
               :cw_world_points => [[10,0],[10,20],[20,0]],
               :cw_world_lines => [
                 [10,0],[10,20],
                 [10,20],[20,0],
                 [20,0],[10,0]
               ],
               :cw_world_edge_normals => [
                 [-20,0],
                 [-10,-20],
                 [0,-10]
               ]
              )
      @arbiter.collide_polygon_polygon?(a,b).should be_true
    end
  end

  describe '#collide_circle_polygon?' do
    it 'should collide overlapping circle and polygon' do
      a = stub(:center_x => 0, :center_y => 0, :radius => 30, :shape_type => :circle)
      b = stub(:center_x => 2, :center_y => 0, :radius => 10, :shape_type => :polygon,
               :cw_world_points => [[10,0],[10,20],[20,0]],
               :cw_world_lines => [
                 [10,0],[10,20],
                 [10,20],[20,0],
                 [20,0],[10,0]
               ],
               :cw_world_edge_normals => [
                 [-20,0],
                 [-10,-20],
                 [0,-10]
               ]
              )
      @arbiter.collide_circle_polygon?(a, b).should be_true
    end

    it 'should not collide overlapping circle and polygon' do
      a = stub(:center_x => 0, :center_y => 0, :radius => 30, :shape_type => :circle)
      b = stub(:center_x => 200, :center_y => 0, :radius => 10, :shape_type => :polygon,
               :cw_world_points => [[10,0],[10,20],[20,0]],
               :cw_world_lines => [
                 [208,0],[208,20],
                 [208,20],[218,0],
                 [218,0],[208,0]
               ],
               :cw_world_edge_normals => [
                 [-20,0],
                 [-10,-20],
                 [0,-10]
               ]
              )
      @arbiter.collide_circle_polygon?(a, b).should be_false
    end
  end

  describe '#collide_aabb_aabb' do
    it 'should collide overlapping boxes' do
      a = stub(:center_x => 0, :center_y => 0, :width => 30, :height => 20, 
          :shape_type => :aabb, :radius => 10,
          :cw_world_points => [
            [-15,10],[15,10],
            [15,-10], [-15,10]
          ],
          :cw_world_lines => [
            [[-15,10],[15,10]],
            [[15,10],[15,-10]],
            [[15,-10],[-15,10]],
            [[-15,10],[-15,10]]
          ],
          :cw_world_edge_normals => [[1,0],[0,1]])
      b = stub(:center_x => 5, :center_y => 5, :width => 10, :height => 2, 
          :shape_type => :aabb, :radius => 10,
          :cw_world_points => [
            [0,6],[10,6],
            [10,4], [0,6]
          ],
          :cw_world_lines => [
            [[0,6],[10,6]],
            [[10,6],[10,4]],
            [[10,4],[0,6]],
            [[0,6],[0,6]]
          ],
          :cw_world_edge_normals => [[1,0],[0,1]])

      @arbiter.collide_aabb_aabb?(a,b).should be_true
    end
  end

  describe '#collide_aabb_circle' do
    it 'should collide overlapping box and circle' do
      a = stub(:center_x => 0, :center_y => 0, :width => 30, :height => 20, 
          :shape_type => :aabb, :radius => 10,
          :cw_world_points => [
            [-15,10],[15,10],
            [15,-10], [-15,10]
          ],
          :cw_world_lines => [
            [[-15,10],[15,10]],
            [[15,10],[15,-10]],
            [[15,-10],[-15,10]],
            [[-15,10],[-15,10]]
          ],
          :cw_world_edge_normals => [[1,0],[0,1]])
      b = stub(:center_x => 5, :center_y => 5, :width => 10, :height => 2, 
          :shape_type => :circle, :radius => 10)

      @arbiter.collide_aabb_circle?(a,b).should be_true
    end
  end

  describe "#find_collisions" do
    it "runs callbacks w/ unique collisions"
  end

end
