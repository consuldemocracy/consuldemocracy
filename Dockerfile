# Use Ruby alpine 2.3.8 as base image
FROM ruby:2.3.8-alpine3.8

# Various environment variables that can be overruled
ENV RAILS_ENV production
ENV DATABASE_ADAPTER postgresql
ENV DATABASE_ENCODING unicode
ENV DATABASE_HOST 127.0.0.1
ENV DATABASE_POOL 5
ENV DATABASE_NAME consul
ENV DATABASE_USER postgres
ENV DATABASE_PASSWORD postgres
ENV RAILS_SERVE_STATIC_FILES true
ENV SMTP_HOST smtp.example.com
ENV SMTP_PORT 587
ENV SMTP_DOMAIN example.com
ENV SMTP_USER username
ENV SMTP_PASSWORD password
ENV SMTP_AUTHENTICATION plain
ENV SMTP_STARTTLS_AUTO true

ENV SECRET_TOKEN 56792feef405a59b18ea7db57b4777e855103882b926413d4afdfb8c0ea8aa86ea6649da4e729c5f5ae324c0ab9338f789174cf48c544173bc18fdc3b14262e4

# Install essential Linux packages
RUN apk --update add build-base nodejs tzdata postgresql-dev postgresql-client libxslt-dev libxml2-dev imagemagick unzip linux-headers

# Files created inside the container repect the ownership
RUN adduser --shell /bin/sh --disabled-password --gecos "" consul

# Define where our application will live inside the image
ENV RAILS_ROOT /var/www/consul

# Create application home. App server will need the pids dir so just create everything in one shot
RUN mkdir -p $RAILS_ROOT/tmp/pids

# Set our working directory inside the image
WORKDIR $RAILS_ROOT

# Use the Gemfiles as Docker cache markers. Always bundle before copying app src.
# (the src likely changed and we don't want to invalidate Docker's cache too early)
# http://ilikestuffblog.com/2014/01/06/how-to-skip-bundle-install-when-deploying-a-rails-app-to-docker/
COPY Gemfile* ./

# Prevent bundler warnings; ensure that the bundler version executed is >= that which created Gemfile.lock
RUN gem install bundler

# Finish establishing our Ruby environment
RUN if [[ "$RAILS_ENV" == "production" ]]; then bundle install --without development test; else bundle install; fi

# Copy the Rails application into place
COPY . .

# Persistant volumes for attachments and configuration
VOLUME $RAILS_ROOT/config
VOLUME $RAILS_ROOT/public/system/images/attachments

# Define the script we want run once the container boots
# Use the "exec" form of CMD so our script shuts down gracefully on SIGTERM (i.e. `docker stop`)
# CMD [ "config/containers/app_cmd.sh" ]
EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
