class Array
  def self.wrap(thing)
    if thing.is_a? Array
      thing
    else
      [thing]
    end
  end
end
