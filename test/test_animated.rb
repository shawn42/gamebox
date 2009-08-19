require 'helper'
require 'animated'
require 'mocha'

describe 'A new animated behavior' do
  before do
    @rm = stub(:load_animation_set => ['1.png_img_obj','2.png_img_obj'])

    opts = {:level=>"level", :input=>"input", :resources=>@rm}
    @actor = Actor.new opts
    @animated = Animated.new @actor
  end

  it 'should define methods on actor' do
    @actor.respond_to?(:image).should be(true)
    @actor.respond_to?(:start_animating).should be(true)
    @actor.respond_to?(:stop_animating).should be(true)
    @actor.respond_to?(:action=).should be(true)
    @actor.respond_to?(:animated).should be(true)
  end

  it 'shouldn\'t update frame for non-animating' do
    @animated.stop_animating

    @animated.update @animated.frame_update_time+1

    @animated.frame_time.should equal(0)
    @animated.frame_num.should equal(0)
  end

  it 'should update frame for animating' do
    time_passed = @animated.frame_update_time-1
    @animated.update time_passed
    @animated.frame_time.should equal(time_passed)
    @animated.frame_num.should equal(0)

    time_passed_again = 2
    @animated.update time_passed_again
    # we rolled over the time
    @animated.frame_time.should equal(1)
    @animated.frame_num.should equal(1)

    time_passed_again = @animated.frame_update_time
    @animated.update time_passed_again
    # we rolled over the time
    @animated.frame_time.should equal(1)
    @animated.frame_num.should equal(0)
  end

  it 'should stop animating' do
    @animated.stop_animating
    @animated.animating.should equal(false)
  end

  it 'should start animating' do
    @animated.start_animating
    @animated.animating.should equal(true)
  end

  it 'should set the action and animate accordingly'

end
