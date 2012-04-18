require 'helper'

describe ClassFinder do  
  describe "::find" do
    it "finds inflected classname" do
      ClassFinder.find(:class_finder).should == ClassFinder
    end
    
    it "returns nil if not found" do
      ClassFinder.find(:klass_not_found).should be_nil
    end
  end
  
end
