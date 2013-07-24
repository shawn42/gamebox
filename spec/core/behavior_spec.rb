require 'helper'

describe Behavior do
  let(:actor) { create_actor }

  it 'should auto-require behaviors that it depends on' 
  it 'has default react_to impl'
  describe "#reacts_with" do
    it 'adds together reactions for multiple calls'
  end
  describe "#add_behavior" do
    it 'uses the behavior factory to add the behavior to the actor'
  end
  describe "#remove_behavior" do
    it 'tells the actor to drop a behavior by name'
  end

end
