# Helper methods and classes for writing specs for your gamebox application
# def log(*args)
#   # nothing for specs!
# end
include Gamebox
class Gosu::Window
  def initialize(*args, &blk)
    # TODO not sure how to handle this for travis-ci breakage..
    # hopefully travis ci starts working again some day...
    # sometimes causes seg faults if running bundle exec rake
    # autorelease garbage in output if I don't do this
  end
end

module GameboxSpecHelpers
  module ClassMethods
    def inject_mocks(*mock_names_array)
      before { @_mocks_created = create_mocks(*mock_names_array) }
      subject { described_class.new @_mocks_created }
    end
  end

  module InstanceMethods

    def create_actor(type=:actor, args={})
      act = create_conjected_object type, nil, false
      act.configure args.merge(actor_type: type)
      act
    end

    def create_conjected_object(type, args={}, configure=true)
      actor_klass = ClassFinder.find(type)
      raise "Could not find actor class #{type}" unless actor_klass

      mocks = create_mocks *actor_klass.object_definition.component_names
      actor_klass.new(mocks).tap do |actor|
        actor.configure args if configure
      end
    end

    def create_actor_view(type=:actor_view, args={}, configure=true)
      create_conjected_object type, args, configure
    end

    def create_mocks(*args)
      {}.tap do |mocks|
        args.each do |mock_name|
          the_mock = instance_variable_get("@#{mock_name}")
          the_mock ||= mock(mock_name.to_s)
          instance_variable_set "@#{mock_name}", the_mock
          mocks[mock_name.to_sym] = the_mock
        end
      end
    end

    def create_stub_everythings(*args)
      {}.tap do |stubs|
        args.each do |stub_name|
          the_stub = stub_everything(stub_name.to_s)
          instance_variable_set "@#{stub_name}", the_stub
          stubs[stub_name.to_sym] = the_stub
        end
      end
    end

    def expects_no_event(target, event_name)
      args = []
      target.when event_name do |*event_args|
        args << event_args
      end
      yield
      args.should be_empty
    end

    def expects_event(target, event_name, expected_args=[[]])
      args = []
      target.when event_name do |*event_args|
        args << event_args
      end
      yield
      args.should == expected_args
    end

    def evented_stub(wrapped_object)
      EventedStub.new wrapped_object
    end
  end

  def self.included(base)
    base.send :include, InstanceMethods
    base.send :extend, ClassMethods
  end
end

class EventedStub
  extend Publisher
  can_fire_anything
  def initialize(object)
    @inner_stub = object
  end
  def method_missing(name, *args)
    @inner_stub.send name, *args
  end
  def fire(*args)
    super
  end
end

module GameboxAcceptanceSpecHelpers
  class ::MockGosuWindow
    include GosuWindowAPI
    extend Publisher
    can_fire :update, :draw, :button_down, :button_up

    def initialize
      @total_millis = 0
    end

    def update(millis)
      if @total_millis == 0
        Gosu.stubs(:milliseconds).returns 0
        super()
      end
      @total_millis += millis
      Gosu.stubs(:milliseconds).returns @total_millis
      @first_update = false

      super()
    end

    def caption=(new_caption)
    end

    def rotate(*args)
      yield
    end
  end


  class ::TestingStage < Stage
    attr_accessor :actors

    def initialize
      @actors = []
    end

    def create_actor(actor_type, *args)
      super.tap do |act|
        @actors << act
        act.when :remove_me do
          @actors.delete act
        end
      end
    end

    def update(time)
      @physics_manager.update time if @physics_manager
      super
    end
  end

  module MockCalls
    attr_accessor :calls
    def method_missing(*args)
      @calls << args
    end

    def _reset!
      @calls = []
    end
  end

  class ::MockImage
    include MockCalls
    attr_accessor :filename
    def initialize(filename)
      _reset!
      @filename = filename
    end

    def width; 10; end
    def height; 20; end
  end

  class ::MockFont
    attr_accessor :name, :size, :calls
    include MockCalls
    def initialize(name, size)
      _reset!
      @name = name
      @size = size
    end
    def text_width(text)
      size * text.size
    end
    def height
      size
    end
  end


  class ::TestingGame < Game
    construct_with *Game.object_definition.component_names
    public *Game.object_definition.component_names

    def configure
      stage_manager.change_stage_to stage_manager.default_stage
    end

    def stage(&blk)
      stage_manager.current_stage.instance_eval &blk
    end

    def current_stage
      stage_manager.current_stage
    end

    def actors(actor_type)
      stage_manager.current_stage.actors.select { |act| act.actor_type == actor_type }
    end

    def actor(actor_type)
      stage_manager.current_stage.actors.detect { |act| act.actor_type == actor_type }
    end
  end

  module ClassMethods
  end

  module InstanceMethods
    def mock_tiles(filename, width, height)
      context = Conject.default_object_context
      resource_manager = context[:resource_manager]

      [].tap do |tiles|
        (width * height).times do |i|
          tiles << MockImage.new("#{filename}_#{i}")
        end

        resource_manager.stubs(:load_tiles).returns(tiles)
      end
    end

    def mock_image(filename)
      context = Conject.default_object_context
      resource_manager = context[:resource_manager]
      MockImage.new(filename).tap do |img|
        resource_manager.stubs(:load_image).with(filename).returns(img)
      end
    end

    def see_actor_drawn(actor_type)
      act = game.actor(actor_type)
      act.should be
    end

    def see_image_drawn(img)
      img.calls.should_not be_empty
      img.calls.first.first.should == :draw
      img._reset!
    end

    def see_image_not_drawn(img)
      img.calls.should be_empty
    end

    def see_text_drawn(text, opts)
      font = opts[:in]
      font.calls.should_not be_empty
      font.calls.first.first.should == :draw
      font._reset!
    end

    def mock_font(name, size)
      context = Conject.default_object_context
      resource_manager = context[:resource_manager]
      MockFont.new(name, size).tap do |font|
        resource_manager.stubs(:load_font).with(name, size).returns(font)
      end
    end

    def see_stage_ivars(ivar_hash)
      ivar_hash.each do |name, val|
        game.current_stage.instance_variable_get("@#{name}").should == val
      end
    end

    def pause
      game.current_stage.pause
    end
    
    def unpause
      game.current_stage.unpause
    end

    def remove_actor(actor_type)
      act = game.actor(actor_type)
      act.should be
      act.remove
    end

    def see_actor_attrs(actor_type, attrs)
      act = game.actor(actor_type)
      act.should be
      act.should have_attrs(attrs)
    end

    def see_no_actor_attrs(actor_type, *attrs)
      act = game.actor(actor_type)
      act.should be
      act.should have_no_attrs(attrs)
    end

    def update(time, opts={})
      step = opts[:step] || time

      num_updates = time / step
      num_updates.times do
        gosu.update step
      end
      left_over = time % step
      gosu.update left_over unless left_over == 0
    end

    def draw
      gosu.draw 
    end

    def release_key(button_id)
      gosu.button_up button_id
    end

    def press_key(button_id)
      gosu.button_down button_id
    end

    def game
      context = Conject.default_object_context
      @game ||= context[:testing_game].tap do |g|
        g.configure
        input_manager = context[:input_manager]
        input_manager.register g
      end
    end

    def gosu
      @gosu ||= MockGosuWindow.new
    end

  end

  def self.included(base)
    base.send :include, InstanceMethods
    base.send :extend, ClassMethods

    RSpec::Matchers.define :have_actor do |actor_type|
      match do |game|
        !game.stage_manager.current_stage.actors.detect { |act| act.actor_type == actor_type }.nil?
      end
    end

    RSpec::Matchers.define :have_attrs do |expected_attributes|
      match do |actor|
        expected_attributes.each do |key, val|
          actor.send(key).should == val
        end
      end
    end

    RSpec::Matchers.define :have_no_attrs do |expected_attributes|
      match do |actor|
        expected_attributes.each do |name|
          actor.has_attribute?(name).should be_false
        end
      end
    end
  end
end

RSpec.configure do |configuration|
  configuration.include GameboxSpecHelpers
  configuration.include GameboxAcceptanceSpecHelpers

  configuration.before(:each) do
    Conject.instance_variable_set(:@default_object_context, nil)
  end

  configuration.before(:each, acceptance: true) do
    Gamebox.configure do |config|
      config.config_path = "spec/fixtures/"
      config.gfx_path = "spec/fixtures/"
      config.fonts_path = "spec/fixtures/"
      config.music_path = "spec/fixtures/"
      config.sound_path = "spec/fixtures/"
      config.game_name = "Some Title!"
      config.needs_cursor = true
      config.stages = [:testing]
    end

    HookedGosuWindow.stubs(:new).returns(gosu)
  end
end

