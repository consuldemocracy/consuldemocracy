# Mail Server Configuration

This is an example of how to integrate a mailing service with Consul Democracy.

In this example we use [Mailgun](https://www.mailgun.com/).

## Create an account in Mailgun

![Creating an account in Mailgun](../../img/mailserver/mailgun-create-account.png)

* Skip the credit card form
* And activate your account with the link sent by email

## Domain configuration

* Go to the Domains section: ![Mailgun domain section](../../img/mailserver/mailgun-domains.png)
* Since you don't have a domain yet, you should click in the sandbox that is already created
* Remember the following credentials: ![Mailgun sandbox](../../img/mailserver/mailgun-sandbox.png)

## Consul Democracy mailing configuration

* Go to the `config/secrets.yml` file
* Change the lines on the file to configure the mail server under the section `staging`, `preproduction` or `production`, depending on your setup:

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

* Fill `<smtp address>`, `<domain>`, `<user_name>` and `<password>` with your information
* Save the file and restart your Consul Democracy application
