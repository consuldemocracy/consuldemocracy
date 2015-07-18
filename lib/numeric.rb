class Numeric
  def percent_of(n)
    (self.to_f / n * 100).to_i
  end
end