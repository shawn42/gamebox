require 'helper'

describe :positioned do
  subjectify_behavior :positioned

  let(:opts) { {} }
  before do 
    actor.stubs(:has_attributes)
  end

  context "empty options" do
    it 'defines x,y,position on actor' do
      actor.expects(:has_attributes).with(x: 0, y: 0, position: vec2(0,0))
      subject
    end
  end

  it 'updates position on x change' do
    subject

    actor.expects(:position=).with(vec2(1,2))
    actor.stubs(x: 1, y: 2)
    actor.fire(:x_changed)
  end

  it 'updates position on y change' do
    subject

    actor.expects(:position=).with(vec2(1,2))
    actor.stubs(x: 1, y: 2)
    actor.fire(:y_changed)
  end

  context "options passed in" do
    let(:opts) { { x: 5, y: 8} }
    it 'defines x,y,position on actor' do
      actor.expects(:has_attributes).with(x: 5, y: 8, position: vec2(5,8))
      subject
    end
  end

  it "keeps x and y up to date if position changes" do
    subject

    actor.expects(:update_attributes).with(x: 2, y: 3)
    actor.stubs(position: vec2(2,3))
    actor.fire(:position_changed)
  end
end
