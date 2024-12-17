# Mail server configuration

This is an example of how to integrate a mailing service with Consul Democracy.

## Get an account from any email provider

To configure email in Consul Democracy, you will need:

* The _smtp_address_, which is the address of your email provider's SMTP server (e.g., smtp.yourdomain.com).
* The _domain_, which is the domain name of your application.
* The _user_name_ and _password_, which are the credentials provided by your email provider to authenticate with the SMTP server.

## Email configuration in Consul Democracy

1. Go to the `config/secrets.yml` file.
2. On this file, change these lines under the section `staging`, `preproduction` or `production`, depending on your setup:

```yml
  mailer_delivery_method: :smtp
  smtp_settings:
     :address: "<smtp address>"
     :port: 587
     :domain: "<domain>"
     :user_name: "<user_name>"
     :password: "<password>"
     :authentication: "plain"
     :enable_starttls_auto: true
```

3. Fill `<smtp address>`, `<domain>`, `<user_name>` and `<password>` with your information.
4. Save the file and restart your Consul Democracy application.
