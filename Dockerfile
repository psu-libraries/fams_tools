FROM ruby:3.4.11 AS base
ARG UID=1001
WORKDIR /app

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN useradd -l -u ${UID} app -d /app && \
  chown -R app /app

RUN apt-get update && apt-get install -y --no-install-recommends g++ \
    zip \
    unzip \
    openssh-server \
    libmariadb-dev \
    libyaml-dev \
    jq \
    curl \
    && rm -rf /var/lib/apt/lists/*

USER app
COPY --chown=app Gemfile Gemfile.lock /app/
COPY --chown=app .bundle/config /app/.bundle/config
# in the event that bundler runs outside of docker, we get in sync with it's bundler version
RUN gem install bundler -v "$(grep -A 1 "BUNDLED WITH" Gemfile.lock | tail -n 1)"

# - - - - - - - - - - - -
FROM base AS dev
WORKDIR /app
USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    xvfb \
    chromium \
    chromium-driver \
    && ln -s /usr/bin/chromium /usr/local/bin/google-chrome \
    && rm -rf /var/lib/apt/lists/*
USER app
COPY --chown=app . /app
CMD ["/app/bin/startup"]

# - - - - - - - - - - - -
FROM base AS production
WORKDIR /app

COPY --chown=app . /app

RUN bundle config set --local without 'development test' && \
  bundle install && \
  bundle clean && \
  rm -rf /app/.bundle/cache && \
  rm -rf /app/vendor/bundle/ruby/*/cache

RUN RAILS_ENV=production \
    SECRET_KEY_BASE=rails_bogus_key \
    bundle exec rails assets:precompile

USER app
CMD ["/app/bin/startup"]
