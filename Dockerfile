FROM harbor.k8s.libraries.psu.edu/library/ruby-3.1.3-node-16:20231225 as base

WORKDIR /app
RUN useradd -u 205 app -d /app 

RUN apt-get clean
RUN apt-get update 

# Packages for webkit
RUN apt-get install -y --no-install-recommends build-essential \
    x11vnc \
    default-libmysqlclient-dev \
    fluxbox \
    zip \ 
    libqt5webkit5-dev \
    gstreamer1.0-plugins-base \
    gstreamer1.0-tools \
    gstreamer1.0-x xvfb \
    g++ \
    unzip \
    sqlite3 \
    libsqlite3-dev \
    libnss3 \
    wmctrl \
    xvfb \
    qt5-default \
    wget \
    rsync \
    && rm -rf /var/lib/apt/lists/* 

# Add Google Chrome repository
RUN apt-get update && apt-get install -y wget \
    && wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update

# Install Google Chrome
RUN apt-get install -y google-chrome-stable
RUN gem install bundler --no-document -v '2.1.4'

# if this build fails try this: # Install mysql2 gem
# RUN gem install mysql2 -v '0.5.4' --source 'https://rubygems.org/'

# - - - - - - - - - - - -

FROM base as dev 
WORKDIR /app
COPY Gemfile Gemfile.lock /app/
RUN bundle install

RUN mkdir -p parsing_files
RUN mkdir -p spec/fixtures/post_prints 
RUN mkdir -p public/psu
RUN mkdir -p public/log

# - - - - - - - - - - - -

FROM dev as production
WORKDIR /app
USER root 
RUN chmod a+rwx -R /app

RUN chmod -R 775 /app
COPY . /app
# RUN bundler install

RUN bundle exec rails assets:precompile
# RUN RAILS_ENV=production bundle exec rails assets:precompile
USER app 
CMD ["/app/bin/startup"]
