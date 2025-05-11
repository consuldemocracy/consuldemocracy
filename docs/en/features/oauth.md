# OAuth

You can configure authentication services with external OAuth providers, right now Twitter, Facebook, Google, Wordpress, SAML and OpenID Connect are supported.

## 1. Create an App on the platform

For each platform, go to their developers section and follow their guides to create an app.

## 2. Set the authentication URL of your Consul Democracy installation

They'll ask you for the authentication URL of your Consul Democracy installation, and as you can see running `rails routes |grep omniauth` at your Consul Democracy repo locally:

```bash
  user_twitter_omniauth_authorize GET|POST /users/auth/twitter(.:format) users/omniauth_callbacks#passthru
  user_twitter_omniauth_callback GET|POST /users/auth/twitter/callback(.:format) users/omniauth_callbacks#twitter
  user_facebook_omniauth_authorize GET|POST /users/auth/facebook(.:format) users/omniauth_callbacks#passthru
  user_facebook_omniauth_callback GET|POST /users/auth/facebook/callback(.:format) users/omniauth_callbacks#facebook
  user_google_oauth2_omniauth_authorize GET|POST /users/auth/google_oauth2(.:format) users omniauth_callbacks#passthru
  user_google_oauth2_omniauth_callback GET|POST /users/auth/google_oauth2/callback(.:format) users/omniauth_callbacks#google_oauth2
  user_wordpress_oauth2_omniauth_authorize GET|POST /users/auth/wordpress_oauth2(.:format) users/omniauth_callbacks#passthru
  user_wordpress_oauth2_omniauth_callback GET|POST /users/auth/wordpress_oauth2/callback(.:format) users/omniauth_callbacks#wordpress_oauth2
  user_saml_omniauth_authorize GET|POST /users/auth/saml(.:format) users/omniauth_callbacks#passthru
  user_saml_omniauth_callback GET|POST /users/auth/saml/callback(.:format) users/omniauth_callbacks#saml
  user_openid_connect_omniauth_authorize GET|POST /users/auth/openid_connect(.:format) users/omniauth_callbacks#passthru
  user_openid_connect_omniauth_callback GET|POST /users/auth/openid_connect/callback(.:format) users/omniauth_callbacks#openid_connect
```

So for example the URL for Facebook application would be `yourdomain.com/users/auth/facebook/callback`.

## 3. Set the key and secret values

When you complete the application registration you'll get a *key* and *secret* values, those need to be stored at your `config/secrets.yml` file:

### For SAML:
```yaml
saml_idp_metadata_url: "https://your-idp/metadata"
saml_idp_cert_fingerprint: "your-certificate-fingerprint"
```

### For OpenID Connect:
```yaml
openid_connect_client_id: "your-client-id"
openid_connect_client_secret: "your-client-secret"
openid_connect_host: "https://your-oidc-provider"
openid_connect_redirect_uri: "https://your-domain/users/auth/openid_connect/callback"
```

## 4. Enable the feature

Go to the admin panel and enable the feature you want to use:

- For SAML: `feature.saml_login`
- For OpenID Connect: `feature.openid_connect_login`
