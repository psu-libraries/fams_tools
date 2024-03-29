FROM ruby:3.1.3

RUN mkdir /fams_tools
WORKDIR /fams_tools

RUN apt-get clean
RUN apt-get update
# For zipping and unzipping
RUN apt-get install -y zip unzip
# Packages for webkit
RUN apt-get install -y g++ libqt5webkit5-dev gstreamer1.0-plugins-base gstreamer1.0-tools gstreamer1.0-x xvfb

RUN gem install bundler --no-document -v '2.1.4'

COPY Gemfile /fams_tools/Gemfile
COPY Gemfile.lock /fams_tools/Gemfile.lock
RUN bundle install
COPY . /fams_tools

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000
