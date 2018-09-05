FROM ruby:2.5.1

MAINTAINER dxw <rails@dxw.com>

RUN apt-get update && apt-get install -qq -y build-essential libpq-dev nodejs --fix-missing --no-install-recommends

RUN YARN_VERSION=$(curl -sSL --compressed https://yarnpkg.com/latest-version) \
  set -ex \
  && curl -fSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz" \
  && mkdir -p /opt/yarn \
  && tar -xzf yarn-v$YARN_VERSION.tar.gz -C /opt/yarn --strip-components=1 \
  && ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn \
  && ln -s /opt/yarn/bin/yarn /usr/local/bin/yarnpkg \
  && rm yarn-v$YARN_VERSION.tar.gz


ENV INSTALL_PATH /srv/dss
RUN mkdir -p $INSTALL_PATH

WORKDIR $INSTALL_PATH

# set rails environment
ARG RAILS_ENV
ENV RAILS_ENV=${RAILS_ENV:-production}
ENV RACK_ENV=${RAILS_ENV:-production}

COPY Gemfile $INSTALL_PATH/Gemfile
COPY Gemfile.lock $INSTALL_PATH/Gemfile.lock
COPY package.json yarn.lock $INSTALL_PATH/

RUN yarn

RUN gem install bundler

# bundle ruby gems based on the current environment, default to production
RUN echo $RAILS_ENV
RUN \
  if [ "$RAILS_ENV" = "production" ]; then \
    bundle install --without development test --retry 10; \
  else \
    bundle install --retry 10; \
  fi

COPY . $INSTALL_PATH

RUN bundle exec rake AWS_ACCESS_KEY_ID=dummy AWS_SECRET_ACCESS_KEY=dummy AWS_S3_REGION=dummy AWS_S3_BUCKET=dummy SECRET_KEY_BASE=dummy DATABASE_URL=postgresql:does_not_exist --quiet assets:precompile

COPY ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
EXPOSE 3100

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["rails", "server"]
