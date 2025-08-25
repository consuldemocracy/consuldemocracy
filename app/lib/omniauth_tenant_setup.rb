module OmniauthTenantSetup
  class << self
    def twitter(env)
      oauth(env, secrets.twitter_key, secrets.twitter_secret)
    end

    def facebook(env)
      oauth2(env, secrets.facebook_key, secrets.facebook_secret)
    end

    def google_oauth2(env)
      oauth2(env, secrets.google_oauth2_key, secrets.google_oauth2_secret)
    end

    def wordpress_oauth2(env)
      oauth2(env, secrets.wordpress_oauth2_key, secrets.wordpress_oauth2_secret)
    end

    def saml(env)
      saml_auth(env, secrets.saml_sp_entity_id,
                secrets.saml_idp_metadata_url, secrets.saml_idp_sso_service_url,
                secrets.saml_additional_parameters)
    end

    private

      def oauth(env, key, secret)
        unless Tenant.default?
          env["omniauth.strategy"].options[:consumer_key] = key
          env["omniauth.strategy"].options[:consumer_secret] = secret
        end
      end

      def oauth2(env, key, secret)
        unless Tenant.default?
          env["omniauth.strategy"].options[:client_id] = key
          env["omniauth.strategy"].options[:client_secret] = secret
        end
      end

      def saml_auth(env, sp_entity_id, idp_metadata_url, idp_sso_service_url, additional_parameters)
        unless Tenant.default?
          strategy = env["omniauth.strategy"]

          strategy.options[:sp_entity_id] = sp_entity_id if sp_entity_id.present?
          strategy.options[:idp_metadata_url] = idp_metadata_url if idp_metadata_url.present?
          strategy.options[:idp_sso_service_url] = idp_sso_service_url if idp_sso_service_url.present?

          if strategy.options[:issuer].present? && sp_entity_id.present?
            strategy.options[:issuer] = sp_entity_id
          end

          if strategy.options[:idp_metadata].present? && idp_metadata_url.present?
            strategy.options[:idp_metadata] = idp_metadata_url
          end

          if additional_parameters.present? && additional_parameters.is_a?(Hash)
            additional_parameters.each do |key, value|
              strategy.options[key.to_sym] = value if value.present?
            end
          end
        end
      end

      def secrets
        Tenant.current_secrets
      end
  end
end
