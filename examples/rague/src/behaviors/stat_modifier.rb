require 'behavior'
class StatModifier < Behavior
  attr_reader :stats
  def setup
    @stats = {:strength=>@opts[:strength]}
    stat_mod_obj = self
    
    @actor.instance_eval do
      (class << self; self; end).class_eval do
        define_method :[] do |stat|
          stat_mod_obj.stats[stat]
        end
        define_method :apply_stats do |target|
          stat_mod_obj.stats.each do |stat,mod|
            target.stats[stat] += mod
          end
        end
        define_method :remove_stats do |target|
          stat_mod_obj.stats.each do |stat,mod|
            target.stats[stat] -= mod
          end
        end
      end
    end
  end
end