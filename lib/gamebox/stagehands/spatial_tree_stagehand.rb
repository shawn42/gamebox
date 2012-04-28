require 'forwardable'

class SpatialTreeStagehand < Stagehand
  extend Forwardable
  def_delegators :@tree, :calculate_bb, :to_s, :each, :collisions, :query, :valid?

  attr_reader :moved_items

  def setup
    @dead_actors = {}
    @moved_items = {}
    @tree = AABBTree.new
  end

  def items
    @tree.items.keys
  end

  def add(actor)
    # TODO change these to one event? position_changed?
    # item.when :width_changed do |old_w, new_w|
    # item.when :height_changed do |old_h, new_h|

    actor.when :position_changed do move actor end
    actor.when :remove_me do
      remove actor
    end
    @dead_actors.delete actor
    if @tree.include? actor
      @tree.update actor
    else
      @tree.insert actor
    end
  end

  def remove(actor)
    @dead_actors[actor] = actor
    @moved_items.delete actor
    raise "remove #{actor} #{__FILE__}" unless @tree.valid?
  end

  def move(actor)
    @moved_items[actor] = actor
  end

  def reset
    @dead_actors.keys.each do |actor|
      @tree.remove actor
      @moved_items.delete actor
      actor.unsubscribe_all self
    end

    @moved_items.keys.each do |actor|
      @tree.update actor
    end

    @moved_items = {}
    @dead_actors = {}
  end

end
