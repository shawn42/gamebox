require 'helper'


# 
# 
# class SizedActor < Actor
#   def width;12;end
#   def height;10;end
# end

describe :collidable do
  let(:opts) { {} }
  subject { subcontext[:behavior_factory].add_behavior actor, :collidable, opts }

  let!(:subcontext) do 
    it = nil
    Conject.default_object_context.in_subcontext{|ctx|it = ctx}; 
    _mocks = create_mocks *(Actor.object_definition.component_names + ActorView.object_definition.component_names - [:actor, :behavior, :this_object_context])
    _mocks.each do |k,v|
      it[k] = v
    end
    it
  end
  let!(:actor) { subcontext[:actor] }

  before do
    @stage.stubs(:register_collidable)
  end

  describe "aabb shape" do
    let(:opts) do
      {:shape => :aabb,
        :cw_world_points => [
          [-15,10],[15,10],
          [15,-10], [-15,10]
        ]}
    end

    before do
      actor.has_attribute(:width, 12)
      actor.has_attribute(:height, 10)
    end

    it "constructs based on points" do
      subject
      actor.shape_type.should == :aabb
    end
  end

  describe "circle shape" do
    before do
      @behavior_opts = {:shape => :circle}
      @collidable = Collidable.new actor, @behavior_opts
    end

    it 'should recalculate_collidable_cache on update' do
      @collidable.shape.expects(:recalculate_collidable_cache)
      @collidable.update 4
    end

    it 'should relegate methods on actor' do
      @collidable.expects(:width).returns(44)
      actor.width.should == 44
      @collidable.expects(:height).returns(45)
      actor.height.should == 45

      @collidable.expects(:shape_type).returns(:circlez)
      actor.shape_type.should == :circlez
    end

    it 'should calculate center point for circle' do
      actor.x = 3
      actor.y = 6
      @collidable = Collidable.new actor, :shape => :circle, :radius => 20
      @collidable.center_x.should be_within(0.001).of(3)
      @collidable.center_y.should be_within(0.001).of(6)
    end
  end

  describe "polygon shape" do
    it 'should calculate center point for polygon' do
      @collidable = Collidable.new actor, :shape => :polygon, :points => [[0,0],[10,7],[20,10]]
      @collidable.center_x.should be_within(0.001).of(10)
      @collidable.center_y.should be_within(0.001).of(5)
    end

    it 'should translate points to world coords for poly' do
      actor.x = 10
      actor.y = 5
      @collidable = Collidable.new actor, :shape => :polygon, :points => [[0,0],[10,7],[20,10]]
      @collidable.cw_world_points.should == [[10,5],[20,12],[30,15]]
    end

    it 'should translate lines to world coords lines' do 
      @collidable = Collidable.new actor, :shape => :polygon, :points => [[0,0],[10,7],[20,10]]

      @collidable.cw_world_lines.should == [
        [[0,0],[10,7]],
        [[10,7],[20,10]],
        [[20,10],[0,0]]
      ]
    end

    it 'should translate world lines to edge normals'  do
      @collidable = Collidable.new actor, :shape => :polygon, 
        :points => [[0,0],[10,7],[20,10]]

      @collidable.cw_world_edge_normals.should == [
        [-7,10], [-3,10], [10,-20]
      ]
    end

    it 'should cache calcs until reset' do
      @collidable = Collidable.new actor, :shape => :polygon, 
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

      actor.x = 10
      actor.y = 5
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
