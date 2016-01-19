FROM ultrayoshi/ruby-node-phantomjs
MAINTAINER david.morcillo@codegram.com

# Create working directory
ENV APP_HOME /decidimbcn
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# Add source code
ADD . $APP_HOME

# Run rails server by default
CMD ["bundle" "exec" "puma", "-C config/puma.rb"]
