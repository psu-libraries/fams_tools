FROM ruby:2.5.1

RUN mkdir /ai_integration
WORKDIR /ai_integration

RUN apt-get update
RUN apt-get install -y g++ qt5-default libqt5webkit5-dev gstreamer1.0-plugins-base gstreamer1.0-tools gstreamer1.0-x xvfb

COPY Gemfile /ai_integration/Gemfile
COPY Gemfile.lock /ai_integration/Gemfile.lock
RUN bundle install
COPY . /ai_integration

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000
