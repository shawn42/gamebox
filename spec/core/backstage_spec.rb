require 'helper'

describe Backstage do


  it 'should construct' do
    subject.should_not be_nil
  end

  it 'should return nil if not found' do
    subject.get(:foo).should be_nil
  end

  it 'should return the value if found' do
    subject.set(:foo,:foo_val).should == :foo_val
    subject.get(:foo).should == :foo_val
  end

  it 'should replace with new values' do
    subject.set(:foo,:foo_val).should == :foo_val
    subject.get(:foo).should == :foo_val

    subject.set(:foo,:other_val).should == :other_val
    subject.get(:foo).should == :other_val
  end

  it 'should properly offer bracket notation' do
    subject[:foo] = :val
    subject[:foo].should == :val
  end

  it 'should raise if an Actor strolls off backstage' do
    foo = create_actor
    lambda{ subject[:foo] = foo }.should raise_error
  end

end
