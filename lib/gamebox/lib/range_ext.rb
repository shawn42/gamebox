class Range
  def sample
    num = self.min + rand(self.max-self.min)
  end
end
