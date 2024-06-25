load Rails.root.join("app", "models", "abilities", "administrator.rb")

module Abilities
  class Administrator
    alias_method :consul_initialize, :initialize

    def initialize(user)
      consul_initialize(user)

      if Tenant.default?
        cannot :update, Setting::LocalesSettings
      end
    end
  end
end
