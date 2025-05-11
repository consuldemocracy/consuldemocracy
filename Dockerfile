FROM ruby:3.2.8-bookworm

ENV DEBIAN_FRONTEND=noninteractive

# Install essential Linux packages
RUN apt-get update -qq \
 && apt-get install -y \
    build-essential \
    cmake \
    imagemagick \
    libappindicator1 \
    libpq-dev \
    libxss1 \
    memcached \
    pkg-config \
    postgresql-client \
    redis-tools \
    wget \
    xvfb \
 && rm -rf /var/lib/apt/lists/*

# Install Node.js
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - \
 && apt-get install -y nodejs \
 && rm -rf /var/lib/apt/lists/*

# Install wkhtmltopdf
RUN wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.bullseye_amd64.deb \
 && dpkg -i wkhtmltox_0.12.6.1-3.bullseye_amd64.deb || true \
 && apt-get -f install -y \
 && rm wkhtmltox_0.12.6.1-3.bullseye_amd64.deb

# Install Chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
 && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list \
 && apt-get update \
 && apt-get install -y google-chrome-stable \
 && rm -rf /var/lib/apt/lists/*

# Install Chrome WebDriver
RUN CHROME_VERSION=$(google-chrome --version | awk '{ print $3 }' | awk -F'.' '{ print $1 }') \
 && CHROMEDRIVER_VERSION=$(curl -s "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_$CHROME_VERSION") \
 && wget -q "https://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip" \
 && unzip chromedriver_linux64.zip \
 && mv chromedriver /usr/local/bin/chromedriver \
 && chmod +x /usr/local/bin/chromedriver \
 && rm chromedriver_linux64.zip

# Install Yarn
RUN npm install -g yarn

# Create app directory
WORKDIR /app

# Install app dependencies
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Install JavaScript dependencies
COPY package.json yarn.lock ./
RUN yarn install

# Copy the rest of the application
COPY . .

# Precompile assets
RUN bundle exec rake assets:precompile

# Add a script to be executed every time the container starts
COPY docker-entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

# Start the main process
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
