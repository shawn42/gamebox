require File.join(File.dirname(__FILE__),'helper')

describe SpatialTreeStagehand do
  subject { SpatialTreeStagehand.new :stage, {}}
  let(:tree) { subject.instance_variable_get('@tree') }

  describe "#items" do
    it "returns all the items" do
      tree.instance_variable_set("@items", :keys => :values)
      subject.items.should == [:keys]
    end
  end


end
