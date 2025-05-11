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
      unless Tenant.default?
        env["omniauth.strategy"].options[:idp_metadata_url] = secrets.saml_idp_metadata_url
        env["omniauth.strategy"].options[:idp_cert_fingerprint] = secrets.saml_idp_cert_fingerprint
      end
    end

    def openid_connect(env)
      unless Tenant.default?
        env["omniauth.strategy"].options[:client_id] = secrets.openid_connect_client_id
        env["omniauth.strategy"].options[:client_secret] = secrets.openid_connect_client_secret
        env["omniauth.strategy"].options[:client_options] = {
          host: secrets.openid_connect_host,
          identifier: secrets.openid_connect_client_id,
          secret: secrets.openid_connect_client_secret,
          redirect_uri: secrets.openid_connect_redirect_uri,
          authorization_endpoint: "/authorize",
          token_endpoint: "/token",
          userinfo_endpoint: "/userinfo"
        }
      end
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

      def secrets
        Tenant.current_secrets
      end
  end
end
