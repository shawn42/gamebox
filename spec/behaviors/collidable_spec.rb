require 'helper'

describe :collidable do
  let(:opts) { {} }
  subject { subcontext[:behavior_factory].add_behavior actor, :collidable, opts }

  let(:director) { evented_stub(stub_everything('director')) }
  let!(:subcontext) do 
    it = nil
    Conject.default_object_context.in_subcontext{|ctx|it = ctx}; 
    _mocks = create_mocks *(Actor.object_definition.component_names + ActorView.object_definition.component_names - [:actor, :behavior, :this_object_context])
    _mocks.each do |k,v|
      it[k] = v
      it[:director] = director
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

    it "constructs based on points" do
      subject
      actor.shape_type.should == :aabb
    end
  end

  describe "circle shape" do
    let(:opts) do
      {shape: :circle, radius: 20}
    end

    it 'should recalculate_collidable_cache on position_changed' do
      subject
      actor.shape.expects(:recalculate_collidable_cache)
      actor.react_to :position_changed
    end

    it 'should calculate center point for circle' do
      actor.has_attributes x: 3, y: 6
      subject

      actor.center_x.should be_within(0.001).of(3)
      actor.center_y.should be_within(0.001).of(6)
    end
  end

  describe "polygon shape" do
    let(:opts) do
      {:shape => :polygon, :points => [[0,0],[10,7],[20,10]]}
    end

    it 'should calculate center point for polygon' do
      subject
      actor.center_x.should be_within(0.001).of(10)
      actor.center_y.should be_within(0.001).of(5)
    end

    it 'should translate points to world coords for poly' do
      actor.has_attributes x: 10, y: 5
      subject
      actor.cw_world_points.should == [[10,5],[20,12],[30,15]]
    end

    it 'should translate lines to world coords lines' do 
      subject
      actor.cw_world_lines.should == [
        [[0,0],[10,7]],
        [[10,7],[20,10]],
        [[20,10],[0,0]]
      ]
    end

    it 'should translate world lines to edge normals'  do
      subject

      actor.cw_world_edge_normals.should == [
        [-7,10], [-3,10], [10,-20]
      ]
    end

    it 'should cache calcs until reset' do
      subject
      # prime the cache
      actor.cw_world_points.should == [[0,0],[10,7],[20,10]]
      actor.cw_world_lines.should == [
        [[0,0],[10,7]],
        [[10,7],[20,10]],
        [[20,10],[0,0]]
      ]
      actor.cw_world_edge_normals.should == [
        [-7,10], [-3,10], [10,-20]
      ]

      actor.x = 10
      actor.y = 5
      actor.cw_world_points.should == [[0,0],[10,7],[20,10]]
      actor.cw_world_lines.should == [
        [[0,0],[10,7]],
        [[10,7],[20,10]],
        [[20,10],[0,0]]
      ]
      actor.cw_world_edge_normals.should == [
        [-7,10], [-3,10], [10,-20]
      ]

      # triggers the recalc cache
      director.fire :update, 4

      actor.cw_world_points.should == [[10,5],[20,12],[30,15]]
      actor.cw_world_lines.should == [
        [[10,5],[20,12]],
        [[20,12],[30,15]],
        [[30,15],[10,5]]
      ]
      actor.cw_world_edge_normals.should == [
        [-7,10], [-3,10], [10,-20]
      ]

    end
  end

end
