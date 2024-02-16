FROM harbor.k8s.libraries.psu.edu/library/ruby-3.1.3-node-16:latest as base

WORKDIR /app
RUN useradd -u 205 app -d /app 
RUN mkdir -p fams_tools/tmp && mkdir -p fams_tools/vendor/cache

RUN apt-get clean
RUN apt-get update

# Packages for webkit
RUN apt-get install -y build-essential \
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
    rsync \
    libsqlite3-dev \
    libnss3 \
    wmctrl \
    xvfb \
    qt5-default

RUN gem install bundler --no-document -v '2.1.4'

# if this build fails try this: # Install mysql2 gem
# RUN gem install mysql2 -v '0.5.4' --source 'https://rubygems.org/'

# - - - - - - - - - - - - - - - - - - - - - - - - - - - -

FROM base as app 
# ENV RAILS_ENV=production # The startup script defaults to development, change to production if need be
WORKDIR /app/fams_tools
RUN chmod 775 /app
COPY Gemfile Gemfile.lock /app/fams_tools/
RUN bundle install

RUN mkdir -p parsing_files
RUN mkdir -p spec/fixtures/post_prints 
RUN mkdir -p public/psu
RUN mkdir -p public/log
# RUN mkdir -p log/ && touch log/development.log && chmod -R 0664 log/

# Add Google Chrome repository
RUN apt-get update && apt-get install -y wget \
    && wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update

# Install Google Chrome
RUN apt-get install -y google-chrome-stable

# Relevant Web Application Files 
COPY app /app/fams_tools/app
COPY bin /app/fams_tools/bin
COPY config /app/fams_tools/config
COPY db /app/fams_tools/db
COPY lib /app/fams_tools/lib
COPY public /app/fams_tools/public
COPY spec /app/fams_tools/spec
COPY tmp /app/fams_tools/tmp
COPY test /app/fams_tools/test
COPY vendor /app/fams_tools/vendor
COPY Capfile /app/fams_tools/
COPY config.ru /app/fams_tools/
COPY LICENSE /app/fams_tools/
COPY Makefile /app/fams_tools/
COPY package.json /app/fams_tools/
COPY Rakefile /app/fams_tools/
COPY README.md /app/fams_tools/
COPY .rspec /app/fams_tools/
COPY .rubocop_todo.yml /app/fams_tools/
COPY .rubocop.yml /app/fams_tools/
COPY .ruby-version /app/fams_tools/

RUN chown -R app /app/fams_tools/
RUN bundle exec rails assets:precompile --trace
USER app
CMD ["/app/fams_tools/bin/startup"]
