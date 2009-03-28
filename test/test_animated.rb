require 'helper'
require 'animated'
require 'mocha'

describe 'A new animated behavior' do

  it 'should define methods on actor' do
    rm = stub(:load_animation_set => ['1.png_img_obj','2.png_img_obj'])

    @actor = Actor.new "level", "input", rm
    @animated = Animated.new @actor
    @actor.should.respond_to? :image
  end

end
