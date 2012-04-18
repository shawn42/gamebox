require 'helper'

describe :graphical_actor_view do
  # TODO this subjet construction is WAY off now
  let!(:subcontext) do 
    it = nil
    Conject.default_object_context.in_subcontext{|ctx|it = ctx}; 
    _mocks = create_mocks *(Actor.object_definition.component_names + ActorView.object_definition.component_names - [:actor])
    _mocks[:this_object_context] = it
    _mocks.each do |k,v|
      it[k] = v
    end
    it
  end
  subject { subcontext[:actor_view_factory].build actor, {} }
  let(:actor) do 
    subcontext[:actor].tap do |a| 
      a.has_attribute :view, :graphical_actor_view
      a.has_attribute :x, 2
      a.has_attribute :y, 3
      a.has_attribute :image, image
      # TODO no more self publishing of behaviors
      a.has_attribute :graphical, graphical
    end
  end

  let(:graphical) { stub('graphical', tiled?: false) }
  let(:image) { stub('image', width: 10, height: 20, draw:nil) }

  before do
    # inject mocks hack
    @actor = actor
    @stage.stub_everything
  end

  describe "#draw" do
    context "no image" do
      it 'does nothing if actor has no image' do
        subject.draw(:target, 0, 0, 0)
      end
    end

    context "with image" do
      before do
        Color.stubs(:new).returns :color
        actor.stubs(:image).returns(image)
      end

      it 'creates the color with the correct alpha' do
        Color.expects(:new).with(0xFF, 0xFF, 0xFF, 0xFF).returns(:full_color)
        subject.draw(:target, 0, 0, 0)
      end

      it 'handles rotation correctly for physical actors' do
        actor.stubs(:is?).with(:physical).returns(true)
        actor.stubs(:rotation).returns(1.3)

        image.expects(:draw_rot).with(2, 3, 1, 1.3, 0.5, 0.5, 1, 1, :color)
        subject.draw(:target, 0, 0, 1)
      end

      it 'translates using the offsets passed in' do
        actor.stubs(:is?).with(:physical).returns(true)
        actor.stubs(:rotation).returns(1.3)

        image.expects(:draw_rot).with(4, 6, 1, 1.3, 0.5, 0.5, 1, 1, :color)
        subject.draw(:target, 2, 3, 1)
      end

      it 'handles draw correctly for plain actors w/o rotation' do
        image.expects(:draw).with(2, 3, 1, 1, 1, :color)
        subject.draw(:target, 0, 0, 1)
      end

      it 'handles rotation correctly for plain actors w/ rotation' do
        actor.stubs(:rotation).returns(1.3)
        image.expects(:draw_rot).with(2, 3, 1, 1.3, 0.5, 0.5, 1, 1, :color)
        subject.draw(:target, 0, 0, 1)
      end

      it 'handles nil rotation' do
        actor.stubs(:rotation).returns(nil)
        image.expects(:draw_rot).with(2, 3, 1, 0.0, 0.5, 0.5, 1, 1, :color)
        subject.draw(:target, 0, 0, 1)
      end

      it 'scales the image correctly' do
        actor.stubs(:rotation).returns(nil)
        actor.stubs(:x_scale).returns(2)
        actor.stubs(:y_scale).returns(3)

        image.expects(:draw_rot).with(2, 3, 1, 0.0, 0.5, 0.5, 2, 3, :color)
        subject.draw(:target, 0, 0, 1)
      end

      it 'draws correctly for tiled graphical actors' do
        actor.stubs(:rotation).returns(0.0)
        actor.stubs(:is?).with(:graphical).returns(true)
        graphical.stubs(:tiled?).returns(true)
        graphical.stubs(:num_x_tiles).returns(2)
        graphical.stubs(:num_y_tiles).returns(3)

        image.expects(:draw_rot).with(2, 3, 1, 0.0, 1, 1)
        image.expects(:draw_rot).with(2, 23, 1, 0.0, 1, 1)
        image.expects(:draw_rot).with(2, 43, 1, 0.0, 1, 1)
        image.expects(:draw_rot).with(12, 3, 1, 0.0, 1, 1)
        image.expects(:draw_rot).with(12, 23, 1, 0.0, 1, 1)
        image.expects(:draw_rot).with(12, 43, 1, 0.0, 1, 1)

        subject.draw(:target, 0, 0, 1)
      end

    end

  end
end
