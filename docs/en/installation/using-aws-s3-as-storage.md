# Using AWS S3 as file storage

Although Consul Democracy stores most of its data in a PostgreSQL database, in Heroku all files, such as documents or images, must be stored elsewhere, such as AWS S3.

## Adding the gem *aws-sdk-s3*

Add the following line to your *Gemfile_custom*:

```ruby
gem "aws-sdk-s3", "~> 1"
```

And run `bundle install` to apply your changes.

## Adding your credentials in *secrets.yml*

This guide assumes you have an Amazon account configured to use S3 and that you have created a bucket for your instance of Consul Democracy. It is strongly recommended to use a different bucket for each instance (production, preproduction, staging).

You will need the following information:

- The **name** of the S3 bucket.
- The **region** of the S3 bucket (`eu-central-1` for UE-Francfort for example).
- An **access_key** and a **secret_key** with read/write permission to that bucket.

**WARNING:** It is recommended to create IAM users (Identity and Access Management) who only have read/write permissions for the bucket you intend to use for that specific instance of Consul Democracy.

Once you have these pieces of information, you can save them as environment variables of the instance running Consul Democracy. In this tutorial, we save them respectively as *S3_BUCKET*, *S3_REGION*, *S3_ACCESS_KEY_ID* and *S3_SECRET_ACCESS_KEY*.

```bash
heroku config:set S3_BUCKET=example-bucket-name S3_REGION=eu-west-example S3_ACCESS_KEY_ID=xxxxxxxxx S3_SECRET_ACCESS_KEY=yyyyyyyyyy
```

Now add the following block to your *secrets.yml* file:

```yaml
production:
  s3:
    access_key_id: <%= ENV["S3_ACCESS_KEY_ID"] %>
    secret_access_key: <%= ENV["S3_SECRET_ACCESS_KEY"] %>
    region: <%= ENV["S3_REGION"] %>
    bucket: <%= ENV["S3_BUCKET"] %>
```

## Enabling the use of S3 in the application

First, add the following line inside the `class Application < Rails::Application` class in the `config/application_custom.rb` file:

```ruby
# Store uploaded files on the local file system (see config/storage.yml for options).
config.active_storage.service = :s3
```

Then, uncomment the s3 block that you will find in the *storage.yml* file:

```yaml
s3:
  service: S3
  access_key_id: <%= Rails.application.secrets.dig(:s3, :access_key_id) %>
  secret_access_key: <%= Rails.application.secrets.dig(:s3, :secret_access_key) %>
  region: <%= Rails.application.secrets.dig(:s3, :region) %>
  bucket: <%= Rails.application.secrets.dig(:s3, :bucket) %>
```

You will need to restart the application to apply the changes.
