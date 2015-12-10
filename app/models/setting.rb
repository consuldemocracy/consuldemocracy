class Setting < ActiveRecord::Base
  validates :key, presence: true, uniqueness: true

  default_scope { order(id: :asc) }

  class << self
    # Public: Gets a setting given a key.
    #
    # key - The setting's key.
    #
    # Returns a Value with the setting.
    def [](key)
      where(key: key).pluck(:value).first
    end

    # Sets a setting value given a key.
    #
    # key   - The setting's key to override.
    # value - The setting's value.
    #
    # Returns the setting's Value.
    def []=(key, value)
      setting = where(key: key).first || new(key: key)
      setting.value = value
      setting.save!
      value
    end
  end
end
