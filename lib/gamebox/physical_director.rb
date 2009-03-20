require 'director'

class PhysicalDirector < Director
  def remove_physical_obj(shape)
    obj_to_kill = @actors.select{|a|a.shape==shape}.first
    obj_to_kill.remove_self
    obj_to_kill.level.unregister_physical_object obj_to_kill
    @actors.delete obj_to_kill
  end
end
