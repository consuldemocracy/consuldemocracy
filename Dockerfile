# ---- Build Stage ----
FROM ruby:3.3.8-bookworm AS build

ENV DEBIAN_FRONTEND=noninteractive
ENV RAILS_ENV=production NODE_ENV=production
ENV RAILS_MASTER_KEY=dummy_key_for_build_only

# Install build dependencies
RUN apt-get update -qq && apt-get install -y \
  build-essential cmake imagemagick libappindicator1 libpq-dev libxss1 memcached pkg-config postgresql-client sudo unzip chromium chromium-driver

WORKDIR /app

# Install Node
COPY .node-version ./
ENV PATH=/usr/local/node/bin:$PATH
RUN curl -sL https://github.com/nodenv/node-build/archive/master.tar.gz | tar xz -C /tmp/ && \
    /tmp/node-build-master/bin/node-build `cat .node-version` /usr/local/node && \
    rm -rf /tmp/node-build-master

COPY .ruby-version ./
COPY Gemfile* ./
RUN bundle install

COPY package* ./
RUN npm install

COPY . .

# RUN bundle exec rails assets:precompile

# ---- Final Stage ----
FROM ruby:3.3.8-bookworm

ENV DEBIAN_FRONTEND=noninteractive
ENV RAILS_ENV=production NODE_ENV=production
ENV PATH=/usr/local/node/bin:$PATH

WORKDIR /app

# Install runtime dependencies only (no build-essential, etc.)
RUN apt-get update -qq && apt-get install -y \
  imagemagick libappindicator1 libpq-dev libxss1 memcached pkg-config postgresql-client sudo unzip chromium chromium-driver

# Create user, set up permissions, etc. (repeat as in your original Dockerfile)
RUN adduser --shell /bin/bash --disabled-password --gecos "" consul \
 && adduser consul sudo \
 && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN echo 'Defaults secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/bundle/bin:/usr/local/node/bin"' > /etc/sudoers.d/secure_path
RUN chmod 0440 /etc/sudoers.d/secure_path

RUN mkdir -p /app/tmp/pids

# Copy only what you need from the build stage
COPY --from=build /usr/local/node /usr/local/node
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /app /app
RUN mkdir -p /app/tmp/cache && chown -R consul:consul /app/tmp

# Set permissions for master.key
RUN chmod 600 /app/config/master.key && chown consul:consul /app/config/master.key

ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
