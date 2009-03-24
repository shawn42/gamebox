require 'director'

class PhysicalDirector < Director
  def find_physical_obj(shape)
    @actors.select{|a|a.shape==shape}.first
  end

  def remove_physical_obj(shape)
    act = find_physical_obj shape
    act.remove_self
  end

  def actor_removed(act)
    act.level.unregister_physical_object act if act.is? :physical
  end
end
