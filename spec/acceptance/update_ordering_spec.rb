require 'helper'

describe "Updates and their order", acceptance: true do

  define_behavior :double_value do |beh|
    beh.requires :director
    beh.setup do
      actor.has_attributes value: 1
      director.when :update, :pre do |time|
        actor.value *= 2
      end
    end
  end

  define_behavior :plus_one do |beh|
    beh.requires :director
    beh.setup do
      actor.has_attributes value: 1
      director.when :update, :update do |time|
        actor.value += 1
      end
    end
  end

  define_behavior :triple_value do |beh|
    beh.requires :director
    beh.setup do
      actor.has_attributes value: 1
      director.when :update, :post do |time|
        actor.value *= 3
      end
    end
  end

  define_actor :math_man do
    has_behaviors :triple_value, :double_value, :plus_one
  end


  it 'updates get fired in the correct order' do
    game.stage do |stage| # instance of TestingStage
      create_actor :math_man
    end

    see_actor_attrs :math_man, value: 1
    update 10

    see_actor_attrs :math_man, value: 9

  end

  it 'modifies update order from the stage' do
    game.stage do |stage| # instance of TestingStage
      director.update_slots = [:update, :post, :pre ]
      create_actor :math_man
    end

    see_actor_attrs :math_man, value: 1
    update 10

    see_actor_attrs :math_man, value: 12

  end
end
