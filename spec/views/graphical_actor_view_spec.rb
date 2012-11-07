require 'helper'

describe :graphical_actor_view do
  let(:image) { stub('image', width: 10, height: 20) }
  let(:actor) { @actor }

  subjectify_actor_view(:graphical_actor_view)

  before do
    actor_stubs actor,
      view: :graphical_actor_view,
      x: 2,
      y: 3,
      tiled: nil,
      num_x_tiles: nil,
      num_y_tiles: nil,
      do_or_do_not: nil

  end


  describe "#draw" do
    context "no image" do
      it 'does nothing if actor has no image' do
        subject.draw(:target, 0, 0, 0)
      end
    end

    context "with image" do
      before do
        actor_stubs actor, image: image
        Color.stubs(:new).returns :color
      end

      it 'creates the color with the correct alpha' do
        image.stubs(draw: nil)
        Color.expects(:new).with(0xFF, 0xFF, 0xFF, 0xFF).returns(:full_color)
        subject.draw(:target, 0, 0, 0)
      end

      it 'translates using the offsets passed in' do
        actor_stubs actor, rotation: 1.3
        image.expects(:draw_rot).with(4, 6, 1, 1.3, 0.5, 0.5, 1, 1, :color)
        subject.draw(:target, 2, 3, 1)
      end

      it 'handles draw correctly for plain actors w/o rotation' do
        image.expects(:draw).with(2, 3, 1, 1, 1, :color)
        subject.draw(:target, 0, 0, 1)
      end

      it 'handles rotation correctly for plain actors w/ rotation' do
        actor_stubs actor, rotation: 1.3
        image.expects(:draw_rot).with(2, 3, 1, 1.3, 0.5, 0.5, 1, 1, :color)
        subject.draw(:target, 0, 0, 1)
      end

      it 'scales the image correctly' do
        actor_stubs actor, 
          rotation: 3,
          x_scale: 2,
          y_scale: 3

        image.expects(:draw_rot).with(2, 3, 1, 3, 0.5, 0.5, 2, 3, :color)
        subject.draw(:target, 0, 0, 1)
      end

      it 'draws correctly for tiled graphical actors' do
        actor_stubs actor, 
          tiled: true,
          num_x_tiles: 2,
          num_y_tiles: 3

        image.expects(:draw).with(2, 3, 1, 1, 1)
        image.expects(:draw).with(2, 23, 1, 1, 1)
        image.expects(:draw).with(2, 43, 1, 1, 1)
        image.expects(:draw).with(12, 3, 1, 1, 1)
        image.expects(:draw).with(12, 23, 1, 1, 1)
        image.expects(:draw).with(12, 43, 1, 1, 1)

        subject.draw(:target, 0, 0, 1)
      end

    end

  end
end
