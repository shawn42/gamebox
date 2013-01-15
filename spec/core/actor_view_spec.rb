require 'helper'

describe ActorView do

  let!(:subcontext) do 
    it = nil
    Conject.default_object_context.in_subcontext{|ctx|it = ctx}; 
    _mocks = create_mocks *(Actor.object_definition.component_names + ActorView.object_definition.component_names - [:actor, :this_object_context])
    _mocks.each do |k,v|
      it[k] = v
    end
    it
  end
  subject { subcontext[:actor_view] }
  let!(:actor) { subcontext[:actor] }

  it 'should be layered 0/1 by default' do
    subject.layer.should == 0
    subject.parallax.should == 1
  end

  it 'should accept layered behavior params from actor' do
    actor.has_attribute :layer, 6
    actor.has_attribute :parallax, 3

    subject.layer.should == 6
    subject.parallax.should == 3
  end

  # TODO move these to visible behavior spec
  # it 'should register for show events' do
  #   @stage.expects(:register_drawable).with(subject)
  #   actor.react_to :show
  # end

  # it 'should register for hide events' do
  #   @stage.expects(:unregister_drawable).with(subject)
  #   actor.react_to :hide
  # end

  # it 'should register for remove events' do
  #   @stage.expects(:unregister_drawable).with(subject)
  #   actor.react_to :remove
  # end

  describe ".define" do
    it 'should call setup on creation'
      # ActorView.any_instance.expects :configure
  end

    
  it 'should manage a cached surface for drawing (possibly use record{})' 
end
