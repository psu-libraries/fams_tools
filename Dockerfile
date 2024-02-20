FROM harbor.k8s.libraries.psu.edu/library/ruby-3.1.3-node-16:20231225 as base
ARG UID=1000
WORKDIR /app

RUN useradd -u ${UID} app -d /app 
RUN chown -R app /app

RUN apt-get clean
RUN apt-get update 

# For zipping and unzipping
RUN apt-get install -y zip unzip
# Packages for webkit
RUN apt-get install -y --no-install-recommends g++ \
    libqt5webkit5-dev \ 
    gstreamer1.0-plugins-base \
    gstreamer1.0-tools \
    gstreamer1.0-x \
    libmariadb-dev \
    libmariadbclient-dev \
    xvfb \
    qt5-default \
    && rm -rf /var/lib/apt/lists/* 

# Look @scholarsphere and how it installs bundler, 
RUN gem install bundler --no-document -v '2.1.4'
USER app 
COPY --chown=app Gemfile Gemfile.lock /app/
RUN bundle config set path 'vendor/bundle'
RUN bundle install

# - - - - - - - - - - - -
FROM base as dev 
WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends x11vnc \
    libsqlite3-dev \
    fluxbox \
    build-essential \
    wget \
    default-libmysqlclient-dev \
    sqlite3 \
    rsync \
    libnss3 \
    wmctrl \
    google-chrome-stable \
    && rm -rf /var/lib/apt/lists/* 

# Debug : 
RUN mkdir -p app/parsing_files
RUN mkdir -p spec/fixtures/post_prints 
RUN mkdir -p public/psu
RUN mkdir -p public/log

RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list

COPY --chown=app . /app
USER app
CMD ["/app/bin/startup"]

# - - - - - - - - - - - -

FROM base as production
WORKDIR /app

RUN chown -R app /app
RUN chmod a+rwx -R /app
RUN chmod -R 775 /app
COPY --chown=app . /app

RUN RAILS_ENV=production bundle exec rails assets:precompile
USER app 
CMD ["/app/bin/startup"]
