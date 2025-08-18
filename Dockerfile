# syntax=docker/dockerfile:1
# check=error=true

# This Dockerfile is designed for production, not development. Use with Kamal or build'n'run by hand:
# docker build -t consuldemocracy .
# docker run -d -p 80:3000 -e RAILS_SECRET_KEY_BASE=<secret_key_base> --name consuldemocracy consuldemocracy
# Note that running by hand won't work when using postgresql.

# For a containerized dev environment, see Dev Containers: https://guides.rubyonrails.org/getting_started_with_devcontainer.html

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.3.8
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
ENV RAILS_ROOT=/var/www/consul
WORKDIR $RAILS_ROOT

# Install base packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

# Throw-away build stage to reduce size of final image
FROM base AS build

# Install packages needed to build gems and node modules
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libyaml-dev node-gyp pkg-config python-is-python3 && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install JavaScript dependencies
COPY .node-version ./
ENV PATH=/usr/local/node/bin:$PATH
RUN curl -sL https://github.com/nodenv/node-build/archive/master.tar.gz | tar xz -C /tmp/ && \
    /tmp/node-build-master/bin/node-build `cat .node-version` /usr/local/node && \
    rm -rf /tmp/node-build-master

# Install application gems
COPY Gemfile* .ruby-version ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# Install node modules
COPY package*.json ./
RUN npm install --production

# Copy application code
COPY . .
COPY config/database.yml.example config/database.yml

# Precompiling assets for production without requiring secret SECRET_KEY_BASE
# RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rake assets:precompile


RUN rm -rf node_modules


# Final stage for app image
FROM base

# Set bundle path for final stage
ENV BUNDLE_PATH="/usr/local/bundle"

# Copy built artifacts: gems, application
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build $RAILS_ROOT $RAILS_ROOT

# Run and own only the runtime files as a non-root user for security
RUN groupadd --system --gid 1000 consul && \
    useradd consul --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    mkdir -p tmp && \
    chown -R consul:consul db log storage tmp
USER 1000:1000

ENV EXECJS_RUNTIME="Disabled"
ENV RAILS_SERVE_STATIC_FILES=true

# Entrypoint prepares the database.
ENTRYPOINT ["/var/www/consul/bin/docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
CMD ["./bin/rails", "server"]
