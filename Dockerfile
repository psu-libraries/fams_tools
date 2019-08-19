FROM ruby:2.5.1

RUN mkdir /ai_integration
WORKDIR /ai_integration

COPY Gemfile /ai_integration/Gemfile
COPY Gemfile.lock /ai_integration/Gemfile.lock
RUN bundle install
COPY . /ai_integration

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000
