require 'helper'

describe Stage do
  inject_mocks :input_manager, :actor_factory, :resource_manager, 
    :sound_manager, :config_manager, :director, :this_object_context,
    :timer_manager

  let(:a) { stub('a', layer: 0, parallax: 0) }
  let(:b) { stub('b', layer: 0, parallax: 0) }

  let(:c) { stub('c', layer: 1, parallax: 0) }
  let(:d) { stub('d', layer: 2, parallax: 0) }
  let(:e) { stub('e', layer: 3, parallax: 0) }
  let(:f) { stub('f', layer: 4, parallax: 0) }

  let(:x) { stub('x', layer: 0, parallax: 1) }
  let(:y) { stub('y', layer: 2, parallax: 1) }

  let(:z) { stub('z', layer: 0, parallax: 3) }
  let(:target) { stub }
  let(:viewport) { stub width: 400, height: 300, rotation: Math::PI }

  before do
    target.stubs(:rotate).yields
    @config_manager.stubs(:[]).with(:screen_resolution).returns([800,600])
    @actor_factory.stubs(:director=)
    Viewport.stubs(:new).with(800, 600).returns(viewport)
    @this_object_context.expects(:[]=).with(:viewport, viewport)
    subject.configure(:backstage, {})

    viewport.stubs(:x_offset).with(0).returns(:trans_x_zero)
    viewport.stubs(:y_offset).with(0).returns(:trans_y_zero)
    viewport.stubs(:x_offset).with(1).returns(:trans_x_one)
    viewport.stubs(:y_offset).with(1).returns(:trans_y_one)
    viewport.stubs(:x_offset).with(3).returns(:trans_x_three)
    viewport.stubs(:y_offset).with(3).returns(:trans_y_three)
  end

  it 'should construct' do
    subject.should_not be_nil
  end

  it 'should have access to backstage' do
    subject.backstage.should == :backstage
  end

  it 'registers and draws drawables by parallax and layers' do
    target.expects(:rotate).with(Math::PI, 200, 150).yields
    subject.register_drawable a
    subject.register_drawable b
    subject.register_drawable c
    subject.register_drawable d
    subject.register_drawable e
    subject.register_drawable f
    subject.register_drawable x
    subject.register_drawable y
    subject.register_drawable z

    a.expects(:draw).with(target, :trans_x_zero, :trans_y_zero, 4)
    b.expects(:draw).with(target, :trans_x_zero, :trans_y_zero, 4)
    c.expects(:draw).with(target, :trans_x_zero, :trans_y_zero, 5)
    d.expects(:draw).with(target, :trans_x_zero, :trans_y_zero, 6)
    e.expects(:draw).with(target, :trans_x_zero, :trans_y_zero, 7)
    f.expects(:draw).with(target, :trans_x_zero, :trans_y_zero, 8)
    x.expects(:draw).with(target, :trans_x_one, :trans_y_one, 2)
    y.expects(:draw).with(target, :trans_x_one, :trans_y_one, 3)
    z.expects(:draw).with(target, :trans_x_three, :trans_y_three, 1)

    subject.draw(target)
  end

  it 'should unregister drawables by parallax and layer' do
    subject.register_drawable a
    subject.register_drawable b

    subject.unregister_drawable a
    b.expects(:draw).with(target, :trans_x_zero, :trans_y_zero, 1)

    subject.draw(target)
  end

  it 'should move drawables layers' do 
    subject.register_drawable a
    subject.register_drawable b
    subject.register_drawable x
    subject.register_drawable y

    a.expects(:parallax=).with(1)
    b.expects(:parallax=).with(1)
    a.expects(:layer=).with(4)
    b.expects(:layer=).with(4)

    subject.move_layer 0, 0, 1, 4

    a.expects(:draw).with(target, :trans_x_zero, :trans_y_zero, 3)
    b.expects(:draw).with(target, :trans_x_zero, :trans_y_zero, 3)
    x.expects(:draw).with(target, :trans_x_one, :trans_y_one, 1)
    y.expects(:draw).with(target, :trans_x_one, :trans_y_one, 2)

    subject.draw(target)
  end

end
