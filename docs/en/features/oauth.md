# Authentication with external services (OAuth)

You can configure authentication services with external OAuth providers. Right now, Twitter, Facebook, Google, Wordpress, SAML and OpenID Connect (OIDC) are supported.

## 1. Create an App on the platform

For Twitter, Facebook, Google and Wordpress, go to their developers section and follow their guides to create an app. For SAML, you'll have to configure an Identity Provider (IdP). For OIDC, you'll need to register your application with an OpenID Connect provider.

## 2. Set the authentication URL of your Consul Democracy installation

They'll ask you for the authentication URL of your Consul Democracy installation, and as you can see running `rails routes | grep omniauth` at your Consul Democracy repo locally:

```bash
user_twitter_omniauth_authorize GET|POST /users/auth/twitter(.:format) users/omniauth_callbacks#passthru
user_twitter_omniauth_callback GET|POST /users/auth/twitter/callback(.:format) users/omniauth_callbacks#twitter
user_facebook_omniauth_authorize GET|POST /users/auth/facebook(.:format) users/omniauth_callbacks#passthru
user_facebook_omniauth_callback GET|POST /users/auth/facebook/callback(.:format) users/omniauth_callbacks#facebook
user_google_oauth2_omniauth_authorize GET|POST /users/auth/google_oauth2(.:format) users/omniauth_callbacks#passthru
user_google_oauth2_omniauth_callback GET|POST /users/auth/google_oauth2/callback(.:format) users/omniauth_callbacks#google_oauth2
user_wordpress_oauth2_omniauth_authorize GET|POST /users/auth/wordpress_oauth2(.:format) users/omniauth_callbacks#passthru
user_wordpress_oauth2_omniauth_callback GET|POST /users/auth/wordpress_oauth2/callback(.:format) users/omniauth_callbacks#wordpress_oauth2
user_saml_omniauth_authorize GET|POST /users/auth/saml(.:format) users/omniauth_callbacks#passthru
user_saml_omniauth_callback GET|POST /users/auth/saml/callback(.:format) users/omniauth_callbacks#saml
user_oidc_omniauth_authorize GET|POST /users/auth/oidc(.:format) users/omniauth_callbacks#passthru
user_oidc_omniauth_callback GET|POST /users/auth/oidc/callback(.:format) users/omniauth_callbacks#oidc
```

So for example the URL for Facebook application would be `yourdomain.com/users/auth/facebook/callback`.

## 3. Set the key and secret values

When you complete the application registration you'll get a *key* and *secret* values, those need to be stored at your `config/secrets.yml` file:

```yml
  twitter_key: ""
  twitter_secret: ""
  facebook_key: ""
  facebook_secret: ""
  google_oauth2_key: ""
  google_oauth2_secret: ""
  wordpress_oauth2_key: ""
  wordpress_oauth2_secret: ""
  wordpress_oauth2_site: ""
  saml_sp_entity_id: "https://yoursp.org/entityid"
  saml_idp_metadata_url: "https://youridp.org/api/saml/metadata"
  saml_idp_sso_service_url: "https://youridp.org/api/saml/sso"
  oidc_client_id: "your-oidc-client-id"
  oidc_client_secret: "your-oidc-client-secret"
  oidc_issuer: "https://your-oidc-provider.com"
```
