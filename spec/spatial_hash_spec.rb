require File.join(File.dirname(__FILE__),'helper')


describe 'a new SpacialHash' do
  before do
    @hash = SpatialHash.new 10
  end

  it 'should be constructable' do
    @hash.cell_size.should == 10
  end

  it 'can add a point' do
    pt = Point.new 2, 3
    @hash.add pt
    @hash.instance_variable_get('@buckets')[0][0].first.should == pt
  end

  it 'can add a neg point' do
    pt = Point.new -2, 3
    @hash.add pt
    @hash.instance_variable_get('@buckets')[-1][0].first.should == pt
  end

  it 'can add a square' do
    box = Item.new 2, 3, 12, 13
    @hash.add box

    buckets = @hash.instance_variable_get('@buckets')

    buckets[0][0].first.should == box
    buckets[0][1].first.should == box
    buckets[1][0].first.should == box
    buckets[1][1].first.should == box
  end

  it 'can add a box' do
    box = Item.new 3, 3, 12, 2
    @hash.add box

    buckets = @hash.instance_variable_get('@buckets')
    buckets[0][0].first.should == box
    buckets[1][0].first.should == box

    buckets[1][1].should be_nil
    buckets[0][1].should be_nil
  end

  it 'can remove points' do
    pt = Point.new -2, 3
    @hash.add pt
    @hash.remove pt

    @hash.instance_variable_get('@buckets')[-1][0].should be_empty
  end

  it 'can remove boxes' do
    box = Item.new 2, 3, 12, 13
    @hash.add box

    @hash.remove box

    @hash.instance_variable_get('@buckets')[0][0].should be_empty
    @hash.instance_variable_get('@buckets')[0][1].should be_empty
    @hash.instance_variable_get('@buckets')[1][0].should be_empty
    @hash.instance_variable_get('@buckets')[1][1].should be_empty
  end

  it 'can lookup objects for an x,y location' do
    box = Item.new 2, 3, 12, 13
    @hash.add box

    @hash.items_at(5, 7).include?(box).should be_true
  end

  it 'can rehash all the items' do
    box = Item.new 2, 3, 12, 13
    @hash.add box
    @hash.rehash

    buckets = @hash.instance_variable_get('@buckets')
    buckets[0][0].first.should == box
    buckets[0][1].first.should == box
    buckets[1][0].first.should == box
    buckets[1][1].first.should == box
  end

  it 'can find items in a box'
end

class Point
  include Kvo
  kvo_attr_accessor :x, :y
  def initialize(x,y)
    self.x = x
    self.y = y
  end
end

class Item 
  include Kvo
  kvo_attr_accessor :x, :y, :width, :height
  def initialize(x,y,w=1,h=1)
    self.x = x
    self.y = y
    self.width = w
    self.height = h
  end
end
