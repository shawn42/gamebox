class ActorDefinition
  attr_accessor :behaviors, :attributes, :view_blk, :behavior_blk, :source
  def initialize
    @behaviors = []
    @attributes = []
  end

  def has_behaviors(*behaviors, &blk)
    if block_given?
      collector = MethodMissingCollector.new
      collector.instance_eval &blk
      collector.calls.each do |name, args|
        if args.empty?
          @behaviors << name
        else
          @behaviors << {name => args.first}
        end
      end
    end
    behaviors.each do |beh|
      @behaviors << beh
    end
  end
  alias has_behavior has_behaviors

  def has_attributes(*attributes)
    attributes.each do |att|
      @attributes << att
    end
  end
  alias has_behavior has_behaviors

  def view(&blk)
    @view_blk = blk
  end

  def behavior(&blk)
    @behavior_blk = blk
  end
end

