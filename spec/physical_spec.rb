require File.join(File.dirname(__FILE__),'helper')
require 'physical'
require 'actor'

class CircleActor < Actor
  has_behaviors :physical => {:shape => :circle, 
    :mass => 500,
    :radius => 10}
end

describe 'A new physical behavior' do
  before do
    @stage = stub(:load_animation_set => ['1.png_img_obj','2.png_img_obj'],:register_physical_object => true)

    opts = {:stage=>@stage, :input=>"input", :resources=>"rm"}
    @actor = CircleActor.new opts
    @physical = @actor.physical
  end

  it 'should add methods to its actor' do
    @actor.should.respond_to? :x
    pending 'testing this feels dirty...'
  end

end
