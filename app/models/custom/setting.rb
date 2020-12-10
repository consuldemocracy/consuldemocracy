require_dependency Rails.root.join("app", "models", "setting").to_s

class Setting
  class << self
    alias_method :consul_defaults, :defaults

    def defaults
      consul_defaults.merge({
        "contact.address": "Pazo de Raxoi. Praza do Obradoiro",
        "contact.email": "datosabertos@santiagodecompostela.gal",
        "contact.phone_1": "+34981542300",
        "contact.phone_2": "+34981542357",
        "facebook_handle": "concellosantiago",
        "org_name": "Portal de participación ciudadana - Concello de Santiago de Compostela",
        "twitter_handle": "pazoderaxoi",
        "youtube_handle": "channel/UCSrcC2UgDHIb80vVVRtvoDw"
      })
    end
  end
end
