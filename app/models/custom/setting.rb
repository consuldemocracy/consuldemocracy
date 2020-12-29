require_dependency Rails.root.join("app", "models", "setting").to_s

class Setting
  class << self
    alias_method :consul_defaults, :defaults

    def defaults
      consul_defaults.merge({
        "mailer_from_address": Rails.application.secrets.mailer_from_address,
        "mailer_from_name": Rails.application.secrets.mailer_from_name
      })
    end
  end
end
