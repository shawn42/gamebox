require_relative 'helper'
describe GraphicalActorView do
  let(:actor) { stub('actor', is?: false, when: nil) }
  let(:stage) { stub('stage') }
  let(:screen) { stub('screen') }
  subject { GraphicalActorView.new stage, actor, screen}

  describe "#draw" do
    it 'does nothing if actor has no image' do
      actor.stubs(image: nil)
      subject.draw(:target, 0, 0, 0)
    end
  end
end
