require File.join(File.dirname(__FILE__),'helper')


describe 'A new backstage' do

  before do
    @backstage = Backstage.new
  end

  it 'should construct' do
    @backstage.should_not be_nil
  end

  it 'should return nil if not found' do
    @backstage.get(:foo).should be_nil
  end

  it 'should return the value if found' do
    @backstage.set(:foo,:foo_val).should == :foo_val
    @backstage.get(:foo).should == :foo_val
  end

  it 'should replace with new values' do
    @backstage.set(:foo,:foo_val).should == :foo_val
    @backstage.get(:foo).should == :foo_val

    @backstage.set(:foo,:other_val).should == :other_val
    @backstage.get(:foo).should == :other_val
  end

  it 'should properly offer bracket notation' do
    @backstage[:foo] = :val
    @backstage[:foo].should == :val
  end

  it 'should raise if an Actor strolls off backstage' do
    class Foo < Actor; end
    foo = create_actor :foo

    lambda{ @backstage[:foo] = foo }.should raise_error
  end

end
