module DocumentNumberNormalizer
  def self.call(value)
    value.gsub(/[^a-z0-9]+/i, "").upcase
  end
end
