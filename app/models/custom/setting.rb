require_dependency Rails.root.join("app", "models", "setting").to_s

class Setting
  class << self
    alias_method :consul_defaults, :defaults

    def defaults
      consul_defaults.merge({
        "org_name": "Portal de participación ciudadana - Concello de Santiago de Compostela"
      })
    end
  end
end
