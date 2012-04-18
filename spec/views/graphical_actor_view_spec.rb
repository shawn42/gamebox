require_relative 'helper'
describe :graphical_actor_view do
  # TODO this subjet construction is WAY off now
  subject { create_actor_view }
  let(:actor) { stub('actor', do_or_do_not: nil, x: 2, y: 3) }
  let(:graphical) { stub('graphical', tiled?: false) }
  let(:image) { stub('image', width: 10, height: 20, draw:nil) }
  before do
    # inject mocks hack
    @actor = actor
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
