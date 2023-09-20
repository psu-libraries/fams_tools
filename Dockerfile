FROM ruby:3.1.3 as base

RUN mkdir /fams_tools
WORKDIR /fams_tools

RUN useradd -u 201 fams -d /fams_tools
RUN chown -R fams /fams_tools

RUN apt-get clean
RUN apt-get update
# For zipping and unzipping
RUN apt-get install -y zip unzip
# Packages for webkit
RUN apt-get install -y g++ libqt5webkit5-dev gstreamer1.0-plugins-base gstreamer1.0-tools gstreamer1.0-x xvfb

RUN gem install bundler --no-document -v '2.1.4'

COPY --chown=fams Gemfile /fams_tools/Gemfile
COPY --chown=fams Gemfile.lock /fams_tools/Gemfile.lock
RUN bundle install

FROM base as dev

RUN mkdir -p app/parsing_files
RUN mkdir -p spec/fixtures/post_prints 
RUN mkdir -p public/psu
RUN mkdir -p public/log
RUN chown -R fams /fams_tools

RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list

RUN apt-get update && apt-get install -y x11vnc \
    xvfb \
    fluxbox \
    wget \
    sqlite3 \
    rsync \
    libsqlite3-dev \
    libnss3 \
    wmctrl \
    google-chrome-stable

USER fams
COPY --chown=fams . /fams_tools
CMD ["sleep", "infinity"]

FROM base as production
COPY --chown=fams . /fams_tools
RUN bundle exec rails assets:precompile

USER fams
CMD ["/app/fams_tools/bin/startup"]
