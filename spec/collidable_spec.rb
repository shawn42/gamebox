require File.join(File.dirname(__FILE__),'helper')
require 'collidable'

describe 'A new collidable behavior' do
  before do
    @stage = mock(:register_collidable => nil)
    @actor_opts = {:actor_type => :actor, :stage=>@stage, :input=>"input", :resources=> :rm}
    @actor = Actor.new @actor_opts
  end


  describe "circle shape" do
    before do
      @behavior_opts = {:shape => :circle}
      @collidable = Collidable.new @actor, @behavior_opts
    end

    it 'should recalculate_collidable_cache on update' do
      @collidable.shape.should_receive(:recalculate_collidable_cache)
      @collidable.update 4
    end

    it 'should relegate methods on actor' do
      @collidable.should_receive(:width).and_return(44)
      @actor.width.should == 44
      @collidable.should_receive(:height).and_return(45)
      @actor.height.should == 45

      @collidable.should_receive(:collidable_shape).and_return(:circlez)
      @actor.collidable_shape.should == :circlez
    end

    it 'should calculate center point for circle' do
      @actor.x = 3
      @actor.y = 6
      @collidable = Collidable.new @actor, :shape => :circle, :radius => 20
      @collidable.center_x.should be_close(23, 0.001)
      @collidable.center_y.should be_close(26, 0.001)
    end
  end

  describe "polygon shape" do
    it 'should calculate center point for polygon' do
      @collidable = Collidable.new @actor, :shape => :polygon, :points => [[0,0],[10,7],[20,10]]
      @collidable.center_x.should be_close(10, 0.001)
      @collidable.center_y.should be_close(5, 0.001)
    end

    it 'should translate points to world coords for poly' do
      @actor.x = 10
      @actor.y = 5
      @collidable = Collidable.new @actor, :shape => :polygon, :points => [[0,0],[10,7],[20,10]]
      @collidable.cw_world_points.should == [[10,5],[20,12],[30,15]]
    end

    it 'should translate lines to world coords lines' do 
      @collidable = Collidable.new @actor, :shape => :polygon, :points => [[0,0],[10,7],[20,10]]

      @collidable.cw_world_lines.should == [
        [[0,0],[10,7]],
        [[10,7],[20,10]],
        [[20,10],[0,0]]
      ]
    end

    it 'should translate world lines to edge normals'  do
      @collidable = Collidable.new @actor, :shape => :polygon, 
        :points => [[0,0],[10,7],[20,10]]

      @collidable.cw_world_edge_normals.should == [
        [-7,10], [-3,10], [10,-20]
      ]
    end

    it 'should cache calcs until reset' do
      @collidable = Collidable.new @actor, :shape => :polygon, 
        :points => [[0,0],[10,7],[20,10]]
      # prime the cache
      @collidable.cw_world_points.should == [[0,0],[10,7],[20,10]]
      @collidable.cw_world_lines.should == [
        [[0,0],[10,7]],
        [[10,7],[20,10]],
        [[20,10],[0,0]]
      ]
      @collidable.cw_world_edge_normals.should == [
        [-7,10], [-3,10], [10,-20]
      ]

      @actor.x = 10
      @actor.y = 5
      @collidable.cw_world_points.should == [[0,0],[10,7],[20,10]]
      @collidable.cw_world_lines.should == [
        [[0,0],[10,7]],
        [[10,7],[20,10]],
        [[20,10],[0,0]]
      ]
      @collidable.cw_world_edge_normals.should == [
        [-7,10], [-3,10], [10,-20]
      ]

      @collidable.clear_collidable_cache
      @collidable.cw_world_points.should == [[10,5],[20,12],[30,15]]
      @collidable.cw_world_lines.should == [
        [[10,5],[20,12]],
        [[20,12],[30,15]],
        [[30,15],[10,5]]
      ]
      @collidable.cw_world_edge_normals.should == [
        [-7,10], [-3,10], [10,-20]
      ]

    end
  end

end
