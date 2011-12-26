require_relative 'helper'

describe HookedGosuWindow do
  subject { HookedGosuWindow.new 2, 3, false }

  describe "#needs_cursor?" do
    it 'defaults to nil' do
      subject.needs_cursor.should be_nil
    end

    it 'returns the instance variable' do
      subject.needs_cursor = :foopy
      subject.needs_cursor.should == :foopy
      subject.needs_cursor?.should == :foopy
    end
  end
end
