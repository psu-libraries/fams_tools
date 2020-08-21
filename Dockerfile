FROM ruby:2.5.1

RUN mkdir /fams_tools
WORKDIR /fams_tools

RUN apt-get update
RUN apt-get install -y g++ qt5-default libqt5webkit5-dev gstreamer1.0-plugins-base gstreamer1.0-tools gstreamer1.0-x xvfb

COPY Gemfile /fams_tools/Gemfile
COPY Gemfile.lock /fams_tools/Gemfile.lock
RUN bundle install
COPY . /fams_tools

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000
