require_dependency Rails.root.join("app", "models", "setting").to_s

class Setting
  class << self
    alias_method :consul_defaults, :defaults

    def defaults
      consul_defaults.merge({
        "facebook_handle": "concellosantiago",
        "org_name": "Portal de participación ciudadana - Concello de Santiago de Compostela",
        "twitter_handle": "pazoderaxoi",
        "youtube_handle": "channel/UCSrcC2UgDHIb80vVVRtvoDw"
      })
    end
  end
end
