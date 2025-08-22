# Authentication with external services (OAuth)

You can configure authentication services with external OAuth providers. Right now, Twitter, Facebook, Google, Wordpress and SAML are supported.

## 1. Create an App on the platform

For Twitter, Facebook, Google and Wordpress, go to their developers section and follow their guides to create an app. For SAML, you'll have to configure an Identity Provider (IdP).

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
  saml_additional_parameters: {}
```

### About `saml_additional_parameters`

The `saml_additional_parameters` field is optional. It allows you to send extra query parameters to the Identity Provider (IdP) when initiating a SAML authentication request.

Most configurations will work without it, but some IdPs require additional fields such as tenant identifiers, RelayState, or authentication context.

**Example:**

```yml
saml_additional_parameters: {
  "RelayState": "https://yoursp.org/dashboard",
  "authn_context": "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport",
  "organization": "example-org"
}
```

* **RelayState** → Redirects the user to a specific page after successful login.
* **authn\_context** → Requests a specific authentication method from the IdP.
* **organization** → Example of a custom parameter (useful if your IdP requires tenant/organization information).

If you don’t need extra parameters, you can safely leave it empty:

```yml
saml_additional_parameters: { }
```
