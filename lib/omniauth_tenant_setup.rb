module OmniauthTenantSetup
  class << self
    def twitter
      ->(env) do
        oauth(env, secrets.twitter_key, secrets.twitter_secret)
      end
    end

    def facebook
      ->(env) do
        oauth2(env, secrets.facebook_key, secrets.facebook_secret)
      end
    end

    def google_oauth2
      ->(env) do
        oauth2(env, secrets.google_oauth2_key, secrets.google_oauth2_secret)
      end
    end

    def wordpress_oauth2
      ->(env) do
        oauth2(env, secrets.wordpress_oauth2_key, secrets.wordpress_oauth2_secret)
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
