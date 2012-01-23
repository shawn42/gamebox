require_relative 'helper'

describe AABBTree do
  it 'can be constucted' do
    subject.should be
  end

  describe '#insert' do
    let(:one) { bb('one', 0,0,1,1) }
    let(:two) { bb('two', 5,9,1,1) }
    let(:three) { bb('three', 7,10,5,1) }
    let(:four) { bb('four', -10,-50,20,5) }

    it 'adds a single item' do
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
      found_items.should == [two]

      found_items = []
      subject.reindex two
      subject.reindex three
      subject.insert two
      subject.insert two
      subject.insert four
      subject.query [1,1,10,10] do |item|
        found_items << item
      end
      found_items.should == [two, three]
      subject.valid?.should be_true

      subject.valid?.should be_true
      two.bb = Rect.new -10, -10, 1, 1
      subject.reindex two
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
      subject.reindex two
      found_items = []
      subject.neighbors_of two do |item|
        found_items << item
      end
      found_items.should =~ [three, two]
      subject.valid?.should be_true

      # require 'perftools'

      # PerfTools::CpuProfiler.start("/tmp/gamebox_perf.txt")
     # set_trace_func proc { |event, file, line, id, binding, classname|
     #   printf("%8s %s:%-2d %10s %8s\n", event, file, line, id, classname) if classname == Rect && id == :initialize
     # }

     # GC.disable
      # 800.times do |i|
      #   subject.insert(bb("thing#{i}",i,i,i,i))
      # end

   # set_trace_func nil
      # puts "\nGARBAGE COLLECTION"
      # # Not even close to exact, but gives a rough idea of what's being collected
      # old_objects = ObjectSpace.count_objects.dup
      # ObjectSpace.garbage_collect
      # new_objects = ObjectSpace.count_objects

      # old_objects.each do |k,v|
      #   diff = v - new_objects[k]
      #   puts "#{k} #{diff} diff" if diff != 0
      # end

      # PerfTools::CpuProfiler.stop
    end
  end

  private
  def bb(*args)
    BBItem.new *args
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
