require 'helper'

describe "The basic life cycle of an actor" do
  before do
    Gamebox.configure do |config|
      config.config_path = "spec/fixtures/"
      config.music_path = "spec/fixtures/"
      config.sound_path = "spec/fixtures/"
    end

    Conject.instance_variable_set '@default_object_context', nil
    HookedGosuWindow.stubs(:new).returns(gosu)
  end
  let(:gosu) { MockGosuWindow.new }

  Behavior.define :shooty do |beh|
    beh.requires :director
    beh.setup do
      actor.has_attribute :bullets, opts[:bullets]
      director.when :update do |time|
        actor.bullets -= time
      end
    end
  end

  Behavior.define :death_on_d do |beh|
    beh.requires :input_manager
    # TODO can we rename this to configure?
    beh.setup do
      input_manager.reg :up, KbD do
        actor.remove
      end
    end
  end

  ActorView.define :mc_bane_view do |view|
    view.requires :resource_manager # needs these injected
    view.configure do
      @image = resource_manager.load_actor_image(actor)
    end

    view.draw do |target, x_off, y_off, z|
      @image.draw(4,7)
    end
  end

  # no code is allowed in the actor!
  # all done through behaviors
  Actor.define :mc_bane do |actor|
    actor.has_behavior  shooty: { bullets: 50 }
    actor.has_behavior :death_on_d
    # actor.has_behavior :graphical

    # FEATURE REQUEST
    # actor.has_view do |view|
    #   view.uses :resource_manager
    #   view.configure do
    #   end

    #   view.draw do |target, x_off, y_off, z|
    #   end
    # end
  end


  it 'creates an actor from within stage with the correct behaviors and updates' do
    # going for a capybara style "page" reference for the game
    game.stage do |stage| # instance of TestingStage
      create_actor :mc_bane, x: 250, y: 400
    end
    see_actor_attrs :mc_bane, bullets: 50

    update 10
    see_actor_drawn :mc_bane

    see_actor_attrs :mc_bane, bullets: 40
    game.should have_actor(:mc_bane)

    send_up KbD

    # should have removed himself
    game.should_not have_actor(:mc_bane)

    # TODO interaction of actors could get tested this way as well
    # TODO rendering checks?
  end

  # HELPERS TO EXTRACT
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

  let(:game) { 
    context = Conject.default_object_context
    context[:testing_game].tap do |g|
      g.configure

      input_manager = context[:input_manager]
      input_manager.register g
    end
  }

  def see_actor_drawn(actor_type)
    act = game.actor(actor_type)
    act.should be
    binding.pry
  end

  def see_actor_attrs(actor_type, attrs)
    act = game.actor(actor_type)
    act.should be
    act.should have_attrs(attrs)
  end

  def update(time)
    gosu.update time
  end

  def send_up(button_id)
    gosu.button_up button_id
  end

  def send_down(button_id)
    gosu.button_down button_id
  end
end

# 
#   class Shooty < Behavior
#     construct_with :actor, :director
#     def setup
#       actor.has_attribute :bullets, opts[:bullets]
#       director.when :update do |time|
#         actor.bullets -= time
#       end
#     end
#   end
# 
#   class DeathOnD < Behavior
#     construct_with :actor, :input_manager
#     def setup
#       input_manager.reg :up, KbD do
#         actor.remove
#       end
#     end
#   end
