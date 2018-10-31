class I18nContent < ActiveRecord::Base

  scope :by_key,          ->(key) { where(key: key) }
  scope :begins_with_key, ->(key) { where("key ILIKE ?", "#{key}%") }

  validates :key, uniqueness: true

  translates :value, touch: true
  globalize_accessors

  # flat_hash returns a flattened hash, a hash with a single level of
  # depth in which each key is composed from the keys of the original
  # hash (whose value is not a hash) by typing in the key of the route
  # from the first level of the original hash
  #
  # Examples:
  #
  # hash = {
  #   'key1' => 'value1',
  #   'key2' => { 'key3' => 'value2',
  #               'key4' => { 'key5' => 'value3' } }
  # }
  #
  # I18nContent.flat_hash(hash) = {
  #   'key1' => 'value1',
  #   'key2.key3' => 'value2',
  #   'key2.key4.key5' => 'value3'
  # }
  #
  # I18nContent.flat_hash(hash, 'string') = {
  #   'string.key1' => 'value1',
  #   'string.key2.key3' => 'value2',
  #   'string.key2.key4.key5' => 'value3'
  # }
  #
  # I18nContent.flat_hash(hash, 'string', { 'key6' => 'value4' }) = {
  #   'key6' => 'value4',
  #   'string.key1' => 'value1',
  #   'string.key2.key3' => 'value2',
  #   'string.key2.key4.key5' => 'value3'
  # }

  def self.flat_hash(input, path = nil, output = {})
    return output.update({ path => input }) unless input.is_a? Hash
    input.map { |key, value| flat_hash(value, [path, key].compact.join('.'), output) }
    return output
  end

end
