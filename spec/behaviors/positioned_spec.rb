require 'helper'

describe :positioned do

  subject! { subcontext[:behavior_factory].add_behavior actor, :positioned, opts }
  let(:director) { evented_stub(stub_everything('director')) }
  let(:subcontext) do 
    it = nil
    Conject.default_object_context.in_subcontext{|ctx|it = ctx}; 
    it[:director] = director
    _mocks = create_mocks *(Actor.object_definition.component_names + ActorView.object_definition.component_names - [:actor, :behavior, :this_object_context])
    _mocks.each do |k,v|
      it[k] = v
    end
    it
  end
  let!(:actor) { subcontext[:actor] }
  let(:opts) { {} }

  context "empty options" do
    it 'defines x,y on actor' do
      actor.x.should == 0
      actor.y.should == 0
    end

    it 'defines position' do
      actor.position.should == vec2(0,0)
    end
  end

  it 'keeps position up to date w/ x and y' do
    called = 0
    actor.when(:position_changed) do
      called += 1
    end
    actor.x = 99
    called.should == 1

    actor.y = 8

    called.should == 2
    actor.position.should == vec2(99,8)
  end

  context "options passed in" do
    let(:opts) { { x: 5, y: 8} }
    it 'defines x,y on actor' do
      actor.x.should == 5
      actor.y.should == 8
    end

    it 'defines position on actor' do
      actor.position.should == vec2(5,8)
    end

  end

  it "keeps x and y up to date if position changes" do
    actor.position = vec2(1,2)
    actor.x.should == 1
    actor.y.should == 2
  end
end
