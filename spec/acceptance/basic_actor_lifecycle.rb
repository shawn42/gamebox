require 'helper'

describe "The basic life cycle of an actor" do
  before do
    # TODO
    # Gamebox.configuration do |config|
    #   config.config_path = "spec/fixtures/"
    # end
    Gamebox.configure do |config|
      config.config_path = "spec/fixtures/"
      config.music_path = "spec/fixtures/"
      config.sound_path = "spec/fixtures/"
    end

    Conject.instance_variable_set '@default_object_context', nil
    # NOTE this usually causes gosu to freak out when running tests
    HookedGosuWindow.stubs(:new).returns(gosu)
  end
  let(:gosu) { MockGosuWindow.new }

  class Shooty < Behavior
    attr_accessor :bullets
    def setup
      relegates :bullets
      @bullets = opts[:bullets]
    end

    def update(time)
      @bullets -= time
    end
  end
  class DeathOnD < Behavior
    def setup
      @actor.input_manager.reg :up, KbD do
        @actor.remove_self
      end
    end
  end

  class McBane < Actor
    construct_with *Actor.object_definition.component_names
    public *Actor.object_definition.component_names

    has_behavior :updatable
    has_behavior shooty: { bullets: 50 }
    has_behavior :death_on_d
  end

  it 'creates an actor from within stage with the correct behaviors and updates' do
    # going for a capybara style "page" reference for the game
    game.stage do |stage| # instance of TestingStage
      create_actor :mc_bane, x: 250, y: 400
    end
    see_actor_attrs :mc_bane, bullets: 50

    update 10
    see_actor_attrs :mc_bane, bullets: 40
    game.should have_actor(:mc_bane)

    send_up KbD

    # should have removed himself
    game.should_not have_actor(:mc_bane)

    # TODO interaction of actors could get tested this way as well
    # TODO rendering checks?
  end

  class MockGosuWindow
    include GosuWindowAPI
    extend Publisher
    can_fire :update, :draw, :button_down, :button_up

    def initialize
      @total_millis = 0
    end

    def update(millis)
      @total_millis += millis
      Gosu.stubs(:milliseconds).returns @total_millis
      super()
    end

    def caption=(new_caption)
    end
    # def method_missing(*args)
    #   puts "WOOPS: #{args.inspect}"
    # end
  end

  RSpec::Matchers.define :have_actor do |actor_type|
    match do |game|
      !game.stage_manager.current_stage.actors.detect { |act| act.actor_type == actor_type }.nil?
    end
  end

  RSpec::Matchers.define :have_attrs do |expected_attributes|
    match do |actor|
      expected_attributes.each do |key, val|
        # TODO actor[key].should == val
        actor.send(key).should == val
      end
    end
  end

  class TestingStage < Stage
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
  end

  class TestingGame < Game
    construct_with *Game.object_definition.component_names
    public *Game.object_definition.component_names

    def configure
      stage_manager.change_stage_to :testing
    end

    def stage(&blk)
      stage_manager.current_stage.instance_eval &blk
    end

    def actor(actor_type)
      stage_manager.current_stage.actors.detect { |act| act.actor_type == actor_type }
    end
  end

  # HELPERS TO EXTRACT
  let(:game) { 
    context = Conject.default_object_context
    context[:testing_game].tap do |g|
      g.configure

      input_manager = context[:input_manager]
      input_manager.register g
    end
  }

  def see_actor_attrs(actor_type, attrs)
    act = game.actor(actor_type)
    act.should be
    act.should have_attrs(attrs)
  end

  def update(time)
    game.update time
  end

  def send_up(button_id)
    gosu.button_up button_id
  end

  def send_down(button_id)
    gosu.button_down button_id
  end
end
