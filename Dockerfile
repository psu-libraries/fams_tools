FROM harbor.k8s.libraries.psu.edu/library/ruby-3.1.3-node-16:20231225 as base
ARG UID=1001
WORKDIR /app

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN useradd -l -u ${UID} app -d /app && \
  chown -R app /app

# hadolint ignore=DL3008
RUN apt-get update && apt-get install -y --no-install-recommends g++ \
    libqt5webkit5-dev \ 
    zip \
    unzip \
    gstreamer1.0-plugins-base \
    gstreamer1.0-tools \
    gstreamer1.0-x \
    libmariadb-dev \
    libmariadbclient-dev \
    xvfb \
    qt5-default \
    && rm -rf /var/lib/apt/lists/* 

USER app 
COPY --chown=app Gemfile Gemfile.lock /app/
COPY --chown=app .bundle/config /app/.bundle/config
# in the event that bundler runs outside of docker, we get in sync with it's bundler version
RUN gem install bundler -v "$(grep -A 1 "BUNDLED WITH" Gemfile.lock | tail -n 1)"

# - - - - - - - - - - - -
FROM base as dev 
WORKDIR /app
USER app
COPY --chown=app . /app
CMD ["/app/bin/startup"]

# - - - - - - - - - - - -
FROM base as production
WORKDIR /app

COPY --chown=app . /app

RUN bundle install --without development test && \
  bundle clean && \
  rm -rf /app/.bundle/cache && \
  rm -rf /app/vendor/bundle/ruby/*/cache 

RUN RAILS_ENV=production \
    SECRET_KEY_BASE=rails_bogus_key \
    bundle exec rails assets:precompile

USER app 
CMD ["/app/bin/startup"]