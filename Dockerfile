FROM ruby:2.5.1

RUN bundle config --global frozen 1

WORKDIR /ai_integration


COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

CMD ["./setup.sh"]