require_relative 'helper'

describe AABBTree do

  let(:one) { bb('one', 0,0,1,1) }
  let(:two) { bb('two', 5,9,1,1) }
  let(:three) { bb('three', 7,10,5,1) }
  let(:four) { bb('four', -10,-50,20,5) }

  describe '#insert' do
    it 'adds a single item' do
      subject.insert one
      subject.should be_valid
      subject.should include(one)

      root = root(subject)
      root.object.should == one
      root.bb.should == Rect.new(0,0,2,2)
      root.a.should be_nil
      root.b.should be_nil
    end
  end

  describe "the whole tree" do
    it 'works' do
      # NOTE: its 3am, I'm bastardizing this test case
      subject.insert one
      subject.insert two
      subject.insert three
      subject.size.should == 3
      subject.valid?.should be_true
      # puts subject.to_s

      subject.remove one
      subject.size.should == 2
      # puts subject.to_s

      subject.query one.bb do |node|
        fail "should not have found one since we removed it"
      end

      found_items = []
      subject.query two.bb do |item|
        found_items << item
      end
      found_items.should == [two, three]

      found_items = []
      subject.update two
      subject.update three
      subject.insert four
      subject.query [1,1,10,10] do |item|
        found_items << item
      end
      found_items.should == [two, three]
      subject.valid?.should be_true

      subject.valid?.should be_true
      two.bb = Rect.new -10, -10, 1, 1
      subject.update two
      subject.valid?.should be_true
      found_items = []
      subject.query [1,1,10, 10] do |item|
        found_items << item
      end
      found_items.should == [three]

      them = []
      subject.each do |item|
        them << item
      end
      them.map(&:object_id).size.should == 3
      subject.valid?.should be_true

      them = []
      two.bb = Rect.new 5, 8, 6, 10
      subject.update two
      found_items = []
      subject.collisions two do |item|
        found_items << item
      end
      found_items.should =~ [three]
      subject.valid?.should be_true
    end
  end

  private
  def bb(*args)
    BBItem.new *args
  end

  def root(tree)
    tree.instance_variable_get('@root')
  end

  class BBItem
    extend Publisher
    can_fire :moved, :remove_me
    attr_accessor :name, :bb
    def initialize(name, x,y,w,h)
      @name = name
      @bb = Rect.new x, y, w, h
    end

    def to_s
      "#{name} : #{bb}"
    end
  end
end
