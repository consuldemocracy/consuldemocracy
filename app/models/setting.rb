class Setting < ActiveRecord::Base
  validates :key, presence: true, uniqueness: true

  default_scope { order(id: :asc) }

  class << self
    # Public: Gets a setting given a key. It will query the database to check
    # if it's overriden, and resort to the YAML setting in `application.yml`
    # otherwise.
    #
    # key - The setting's key.
    #
    # Returns a Value with the setting.
    def [](key)
      where(key: key).pluck(:value).first || StaticSetting[key]
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

  # This class acts as a fallback. By default, we try to find an overriden
  # setting in the DB. If not found, we fall back to the default settings
  # put in the static application.yml config file.
  #
  # This way, we keep runtime control of the settings without sacrificing
  # ease of use.
  class StaticSetting < Settingslogic
    source "#{Rails.root}/config/application.yml"
    namespace Rails.env
  end
end
