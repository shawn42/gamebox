require 'helper'
require 'animated'
require 'mocha'

describe 'A new animated behavior' do
  before do
    @rm = stub(:load_animation_set => ['1.png_img_obj','2.png_img_obj'])

    @actor = Actor.new "level", "input", @rm
    @animated = Animated.new @actor
  end

  it 'should define methods on actor' do
    @actor.should.respond_to? :image
    @actor.should.respond_to? :start_animating
    @actor.should.respond_to? :stop_animating
    @actor.should.respond_to? :action=
    @actor.should.respond_to? :animated
  end

  it 'shouldn\'t update frame for non-animating' do
    @animated.stop_animating

    @animated.update Animated::FRAME_UPDATE_TIME+1

    @animated.frame_time.should.equal 0
    @animated.frame_num.should.equal 0
  end

  it 'should update frame for animating' do
    time_passed = Animated::FRAME_UPDATE_TIME-1
    @animated.update time_passed
    @animated.frame_time.should.equal time_passed
    @animated.frame_num.should.equal 0

    time_passed_again = 2
    @animated.update time_passed_again
    # we rolled over the time
    @animated.frame_time.should.equal 1
    @animated.frame_num.should.equal 1

    time_passed_again = Animated::FRAME_UPDATE_TIME
    @animated.update time_passed_again
    # we rolled over the time
    @animated.frame_time.should.equal 1
    @animated.frame_num.should.equal 0
  end

  it 'should stop animating' do
    @animated.stop_animating
    @animated.animating.should.equal false
  end

  it 'should start animating' do
    @animated.start_animating
    @animated.animating.should.equal true
  end

  it 'should set the action and animate accordingly' do
    should.flunk 'finish me'
  end

end
