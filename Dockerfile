# Stage 1: Build dependencies and assets
FROM ruby:3.2.8-slim-bookworm AS builder

ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies required for gem installation and asset compilation
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    build-essential \  
    cmake \           
    curl \             
    git \             
    libpq-dev \        
    pkg-config \       
    postgresql-client \
    sudo \             
    && rm -rf /var/lib/apt/lists/* # Clean up to reduce image size

# Set up work directory
WORKDIR /app

# Install Node.js based on the version specified in .node-version
COPY .node-version ./
ENV PATH=/usr/local/node/bin:$PATH
RUN curl -sL https://github.com/nodenv/node-build/archive/master.tar.gz | tar xz -C /tmp/ && \
    /tmp/node-build-master/bin/node-build "$(cat .node-version)" /usr/local/node && \
    rm -rf /tmp/node-build-master

# Install Ruby dependencies
# Copying just the Gemfile first to leverage Docker layer caching
COPY .ruby-version Gemfile* ./
RUN bundle config set --local without 'development test' && \
    bundle install --jobs=$(nproc) --retry=3

# Install Node.js dependencies
# Copying just package.json files first to leverage Docker layer caching
COPY package*.json ./
RUN npm ci --only=production

# Stage 2: Final image with minimal dependencies
FROM ruby:3.2.8-slim-bookworm

ENV DEBIAN_FRONTEND=noninteractive
ENV RAILS_ENV=production
ENV RAILS_SERVE_STATIC_FILES=true  
ENV RAILS_LOG_TO_STDOUT=true      

# Install only runtime dependencies to keep the image small
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    imagemagick \       
    libpq5 \            
    postgresql-client \ 
    sudo \              
    && rm -rf /var/lib/apt/lists/* # Clean up

# Create consul user for running the application (avoid running as root)
RUN adduser --shell /bin/bash --disabled-password --gecos "" consul && \
    adduser consul sudo && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    echo 'Defaults secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/bundle/bin:/usr/local/node/bin"' > /etc/sudoers.d/secure_path && \
    chmod 0440 /etc/sudoers.d/secure_path

# Set up application directory and create necessary subdirectories
ENV RAILS_ROOT=/var/www/consul
RUN mkdir -p $RAILS_ROOT/tmp/pids $RAILS_ROOT/tmp/cache $RAILS_ROOT/storage && \
    chown -R consul:consul $RAILS_ROOT

# Copy dependencies from the builder stage
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /usr/local/node /usr/local/node
ENV PATH=/usr/local/node/bin:$PATH

# Set working directory
WORKDIR $RAILS_ROOT

# Copy the application code with proper ownership
COPY --chown=consul:consul . .

# Set up the entrypoint script
COPY --chown=consul:consul docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# Default command when container starts
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]