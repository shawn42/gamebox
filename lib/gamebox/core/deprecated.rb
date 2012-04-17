class Actor
  def self.inherited(klass)
    log "Cannot extend #{self} anymore #{klass}"
  end
end
class Behavior
  def self.inherited(klass)
    log "Cannot extend #{self} anymore #{klass}"
  end
end
class ActorView
  def self.inherited(klass)
    log "Cannot extend #{self} anymore #{klass}"
  end
end
