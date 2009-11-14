require 'director'

class PhysicalDirector < Director
  def find_physical_obj(shape)
    @actors.select{|a|a.respond_to?(:shape) && a.shape==shape}.first
  end

  def remove_physical_obj(shape)
    act = find_physical_obj shape
    act.remove_self
    act
  end

  def actor_removed(act)
    act.stage.unregister_physical_object act if act.is? :physical
  end
end
