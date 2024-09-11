# OAuth

You can configure authentication services with external OAuth suppliers, right now Twitter, Facebook and Google are supported.

## 1. Create an App on the platform

For each platform, go to their developers section and follow their guides to create an app.

## 2. Set your Consul Democracy's url

They'll ask you for your Consul Democracy's auth URL, and as you can see running `rake routes` at your Consul Democracy repo locally:

```bash
user_omniauth_authorize GET|POST /users/auth/:provider(.:format)          users/omniauth_callbacks#passthru {:provider=>/twitter|facebook|google_oauth2/}
```

So for example the URL for facebook application would be `yourdomain.com/users/auth/facebook/callback`

## 3. Set key & secret values

When you complete the application registration you'll get a *key* and *secret* values, those need to be stored at your `config/secrets.yml` file:

```yml
  twitter_key: ""
  twitter_secret: ""
  facebook_key: ""
  facebook_secret: ""
  google_oauth2_key: ""
  google_oauth2_secret: ""
```

*NOTE:* Also in the case of Google, verify that the APIs *Contacts API* and *Google+ API* are enabled for the application.
