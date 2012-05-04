require 'helper'

describe TimerManager do
  describe "#add_timer" do
    let(:block) { Proc.new do end }
    it 'adds a timer by name' do
      subject.add_timer 'foo', 45, &block
      subject.timer('foo').should == {
        count: 0, recurring: true,
        interval_ms: 45, callback: block
      }
    end

    it 'raises if a timer already exists by that name' do
      subject.add_timer 'foo', 45, &block
      lambda { subject.add_timer 'foo', 45, &block }.should raise_exception
    end
  end

  describe "#remove_timer" do
    let(:block) { Proc.new do end }
    it 'removes a timer by name' do
      subject.add_timer 'foo', 45, &block
      subject.remove_timer 'foo'

      subject.timer('foo').should_not be
    end
  end

  describe "#update" do
    it 'fires timers that need to be fired and roles up counts if not yet met' do
      calls = 0
      block = Proc.new do calls += 1 end
      subject.add_timer 'foo', 45, &block
      
      subject.update 45
      calls.should == 0

      subject.update 1
      calls.should == 1

      subject.update 90
      calls.should == 2

      subject.update 1
      calls.should == 3
    end

    it 'removes fired non-recurring timmers' do
      calls = 0
      block = Proc.new do calls += 1 end
      subject.add_timer 'foo', 45, false, &block

      subject.update 46
      calls.should == 1

      subject.timer('foo').should_not be
    end
  end

  describe "#pause" do
    it 'pauses current timers' do
      calls = 0
      block = Proc.new do calls += 1 end
      subject.add_timer 'foo', 45, false, &block

      subject.pause
      subject.update 50
      calls.should == 0
    end
  end

  describe "#unpause" do
    it 'unpauses current timers' do
      calls = 0
      block = Proc.new do calls += 1 end
      subject.add_timer 'foo', 45, false, &block

      subject.pause
      subject.update 50
      calls.should == 0

      subject.unpause
      subject.update 50
      calls.should == 1
    end
  end

end
