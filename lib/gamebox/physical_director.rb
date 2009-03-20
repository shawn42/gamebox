require 'director'

class PhysicalDirector < Director
  def remove_physical_obj(shape)
    act = @actors.select{|a|a.shape==shape}.first
    act.remove_self
  end

  def actor_removed(act)
    act.level.unregister_physical_object act if act.is? :physical
  end
end
