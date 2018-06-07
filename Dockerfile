FROM ruby:2.3.6

# Install essential Linux packages
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev postgresql-client nodejs imagemagick sudo

# Test requirements
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
  && apt-get update \
  && apt-get install -y google-chrome-stable \
  && apt-get clean

RUN CHROMEDRIVER_RELEASE=2.38 \
  && CHROMEDRIVER_URL="http://chromedriver.storage.googleapis.com/$CHROMEDRIVER_RELEASE/chromedriver_linux64.zip" \
  && apt-get install unzip \
  && curl --silent --show-error --location --fail --retry 3 --output /tmp/chromedriver_linux64.zip $CHROMEDRIVER_URL \
  && unzip /tmp/chromedriver_linux64.zip chromedriver -d /usr/local/bin \
  && rm /tmp/chromedriver_linux64.zip

# Files created inside the container repect the ownership
RUN adduser --shell /bin/bash --disabled-password --gecos "" consul \
  && adduser consul sudo \
  && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN echo 'Defaults secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/bundle/bin"' > /etc/sudoers.d/secure_path
RUN chmod 0440 /etc/sudoers.d/secure_path

COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh

# Define where our application will live inside the image
ENV RAILS_ROOT /var/www/consul

# Create application home. App server will need the pids dir so just create everything in one shot
RUN mkdir -p $RAILS_ROOT/tmp/pids

# Set our working directory inside the image
WORKDIR $RAILS_ROOT

# Use the Gemfiles as Docker cache markers. Always bundle before copying app src.
# (the src likely changed and we don't want to invalidate Docker's cache too early)
# http://ilikestuffblog.com/2014/01/06/how-to-skip-bundle-install-when-deploying-a-rails-app-to-docker/
COPY Gemfile Gemfile

COPY Gemfile.lock Gemfile.lock

COPY Gemfile_custom Gemfile_custom

# Prevent bundler warnings; ensure that the bundler version executed is >= that which created Gemfile.lock
RUN gem install bundler

# Finish establishing our Ruby enviornment
RUN bundle install --full-index

# Copy the Rails application into place
COPY . .

# Define the script we want run once the container boots
# Use the "exec" form of CMD so our script shuts down gracefully on SIGTERM (i.e. `docker stop`)
#CMD [ "config/containers/app_cmd.sh" ]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
