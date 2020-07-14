# Development Mail Server

This is a example to how integrate a mailing service with a development environment of Consul.

In this example we used [Mailgun](https://www.mailgun.com/).

## Create an account in Mailgun

![Creating an account in Mailgun](../../../.gitbook/assets/mailgun-create-account%20%281%29.png)

* Skip the credit card form
* And activate your account with the link sent by email

## Domain configuration

* Go to the Domains section: ![Mailgun domain section](../../../.gitbook/assets/mailgun-domains%20%281%29.png)
* Since you don't have a domain yet, you should click in the sandbox that is already created;
* Remember the next credentials:

  ![Mailgun sandbox](../../../.gitbook/assets/mailgun-sandbox%20%281%29.png)

## Consul mailing configuration for development environment

* Go to `config/environments/development.rb` file;
* Add the lines on the file to configure the mail server:

```ruby
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.smtp_settings = {
      :address              => '',
      :port                 => 2525,
      :domain               => '',
      :user_name            => '',
      :password             => '',
      :authentication => :plain,
      :enable_starttls_auto => true,
      :ssl => false
  }
```

* Fill, `address`, `domain`, `user_name`, `password` with your information. The file would look like:

![development.rb file](../../../.gitbook/assets/development.rb%20%281%29.png)

## Consul mailing configuration for production environment

* Go to `config/environments/production.rb` file.
* Add the same **action mailer settings** configuration, but now with your production mail server information.
* Pay attention because you will need to change the **port** number to **587**.

You can also use Mailgun to production, adding your custom domain. Mailgun’s logs sent and delivered emails.

