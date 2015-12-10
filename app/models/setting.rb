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

    # Public: Overrides the YAML setting or any previously overriden setting
    # given a key and value.
    #
    # key   - The setting's key to override.
    # value - The setting's value.
    #
    # Returns the setting's Value.
    def override(key, value)
      (where(key: key).first || create(key: key)).update(value: value)
      value
    end

    # Public: Deletes a previously overriden setting.
    #
    # key - The setting key to un-override.
    #
    # Returns the setting's key.
    def delete_override(key)
      where(key: key).first.try(:destroy)
      key
    end

    # Deprecated: Returns a setting's value given a key. Using [] is
    # recommended.
    #
    # key - The setting's key.
    #
    # Returns the Value of the setting.
    def value_for(key)
      self[key]
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
