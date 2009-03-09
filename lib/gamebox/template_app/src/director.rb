# Directors manage actors.
class Director
  attr_accessor :actors

  def initialize
    @actors = []
  end

  def update(time)
    for act in @actors
      act.update time
    end
  end

  def draw(target)
    for act in @actors
      act.draw target
    end
  end


end
