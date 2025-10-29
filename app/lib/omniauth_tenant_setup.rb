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
                secrets.saml_idp_metadata_url, secrets.saml_idp_sso_service_url)
    end

    def oidc(env)
      oidc_auth(env, secrets.oidc_client_id, secrets.oidc_client_secret, secrets.oidc_issuer)
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

      def saml_auth(env, sp_entity_id, idp_metadata_url, idp_sso_service_url)
        env["omniauth.strategy"].options.merge!(
          saml_settings(sp_entity_id, idp_metadata_url, idp_sso_service_url)
        )
      end

      def saml_settings(sp_entity_id, idp_metadata_url, idp_sso_service_url)
        remote_saml_settings(idp_metadata_url).tap do |settings|
          settings[:sp_entity_id] = sp_entity_id if sp_entity_id.present?
          settings[:idp_sso_service_url] = idp_sso_service_url if idp_sso_service_url.present?
          settings[:allowed_clock_drift] = 1.minute
        end
      end

      def remote_saml_settings(idp_metadata_url)
        return {} if idp_metadata_url.blank?

        @remote_saml_settings ||= {}
        @remote_saml_settings[idp_metadata_url] ||= parsed_saml_metadata(idp_metadata_url)
      end

      def parsed_saml_metadata(idp_metadata_url)
        OneLogin::RubySaml::IdpMetadataParser.new.parse_remote_to_hash(idp_metadata_url)
      end

      def oidc_auth(env, client_id, client_secret, issuer)
        strategy = env["omniauth.strategy"]

        strategy.options[:issuer] = issuer if issuer.present?
        strategy.options[:client_options] ||= {}
        strategy.options[:client_options][:identifier] = client_id if client_id.present?
        strategy.options[:client_options][:secret] = client_secret if client_secret.present?
        strategy.options[:client_options][:redirect_uri] = oidc_redirect_uri if oidc_redirect_uri.present?
      end

      def oidc_redirect_uri
        Rails.application.routes.url_helpers.user_oidc_omniauth_callback_url(Tenant.current_url_options)
      end

      def secrets
        Tenant.current_secrets
      end
  end
end
