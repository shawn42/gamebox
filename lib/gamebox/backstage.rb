# Backstage is a place to store things across stages. It does not allow you to store Actors here.
class Backstage
  def initialize
    @storage = {}
  end

  def set(key, value)
    raise "Actors cannot wander back stage!" if value.is_a? Actor
    @storage[key] = value
  end
  alias []= set

  def get(key)
    @storage[key]
  end
  alias [] get
end
