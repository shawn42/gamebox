require 'helper'

describe BehaviorFactory do
  describe "#add_behavior" do
    it "should call #add_behavior on the actor" do
      opts = {foo: 'bar'}
      some_actor = stub("actor")
      some_actor.expects(:add_behavior).with(:some_behavior, opts)

      subject.add_behavior( some_actor, :some_behavior, opts )
    end
  end
end
