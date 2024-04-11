module PercentageCalculator
  def self.calculate(fraction, total)
    return 0.0 if total.zero?

    (fraction * 100.0 / total).round(3)
  end
end
