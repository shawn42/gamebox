require 'helper'

describe HookedGosuWindow do
  class Gosu::Window
    def initialize(*args)
      # TODO not sure how to handle this for travis-ci breakage..
      # sometimes causes seg faults if running bundle exec rake
      # autorelease garbage in output if I don't do this
    end
  end

  subject { HookedGosuWindow.new 2, 3, false }

  it 'should inherit from Gosu::Window' do
    described_class.is_a? Gosu::Window
  end

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

  describe "#update" do
    it 'fires initial update with full millis' do
      Gosu.stubs(:milliseconds).returns 58

      expects_event subject, :update, [[58]] do
        subject.update
      end
    end

    it 'fires initial update with deltas' do
      subject.instance_variable_set('@last_millis', 30)
      Gosu.stubs(:milliseconds).returns 58

      expects_event subject, :update, [[28]] do
        subject.update
      end

    end
  end

  describe "#draw" do
    it 'fires the draw event' do
      expects_event subject, :draw, [[]] do
        subject.draw
      end
    end
  end

  describe "#button_down" do
    it 'fires the button_down event' do
      expects_event subject, :button_down, [[44]] do
        subject.button_down 44
      end
    end
  end

  describe "#button_up" do
    it 'fires the button_up event' do
      expects_event subject, :button_up, [[44]] do
        subject.button_up 44
      end
    end
  end

end
