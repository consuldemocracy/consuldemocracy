FROM ruby:2.2.2

ENV DEBIAN_FRONTEND noninteractive

ENV APP_PATH /app

# this allows to cache installed gems and have faster bundler
ENV BUNDLE_PATH /bundle

# Install nodejs for execjs and postgres-client for 'rails dbconsole'
RUN apt-get update && apt-get install -y nodejs postgresql-client \
  --no-install-recommends && rm -rf /var/lib/apt/lists/*

# Phantomjs
ENV PHANTOM_JS_VERSION 1.9.8-linux-x86_64
RUN apt-get install -y curl bzip2 libfreetype6 libfontconfig \
  --no-install-recommends && rm -rf /var/lib/apt/lists/*
RUN curl -sSL https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-$PHANTOM_JS_VERSION.tar.bz2 | tar xjC /
RUN ln -s /phantomjs-$PHANTOM_JS_VERSION/bin/phantomjs /usr/bin/phantomjs

RUN mkdir -p $APP_PATH

WORKDIR $APP_PATH

COPY . $APP_PATH

CMD ./start
