class Setting
  class LocalesSettings
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :enabled, array: true, default: -> { Setting.enabled_locales }
    attribute :default, default: -> { Setting.default_locale }

    def persisted?
      true
    end

    def update(attributes)
      assign_attributes(attributes)

      Setting.transaction do
        Setting["locales.default"] = default
        Setting["locales.enabled"] = [default, *enabled].join(" ")
      end
    end
    alias_method :update!, :update
  end
end
