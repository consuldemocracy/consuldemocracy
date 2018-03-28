class CastToBoolean

  BOOLEAN_VALUES = {
    true => true,
    'true' => true,
    'yes' => true,
    false => false,
    'false' => false,
    'no' => false,
  }

  def self.call value
    self.new(value).call
  end

  def initialize value
    @value = value
  end

  def call
    cast_to_boolean
  end

  private

  def cast_to_boolean
    return @value unless BOOLEAN_VALUES.keys.include?(@value)
    BOOLEAN_VALUES[@value]
  end


end
# end
