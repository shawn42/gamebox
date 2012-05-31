require 'helper'

describe :positioned do

  subject { subcontext[:behavior_factory].add_behavior actor, :positioned, opts }
  let(:director) { evented_stub(stub_everything('director')) }
  let(:subcontext) do 
    it = nil
    Conject.default_object_context.in_subcontext{|ctx|it = ctx}; 
    _mocks = create_mocks *(Actor.object_definition.component_names + ActorView.object_definition.component_names - [:actor, :behavior, :this_object_context])
    _mocks.each do |k,v|
      it[k] = v
      it[:director] = director
    end
    it
  end
  let!(:actor) { subcontext[:actor] }
  let(:opts) { {} }

  context "empty options" do
    it 'defines x,y on actor' do
      subject
      actor.x.should == 0
      actor.y.should == 0
    end
  end

  it 'rolls up x and y changes to position_changed on update' do
    subject
    actor.x = 99

    expects_event(actor, :position_changed) do
      director.fire :update, 50
    end
  end

  context "options passed in" do
    let(:opts) { { x: 5, y: 8} }
    it 'defines x,y on actor' do
      subject
      actor.x.should == 5
      actor.y.should == 8
    end
  end
end
