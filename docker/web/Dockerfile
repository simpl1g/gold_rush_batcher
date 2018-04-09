FROM ruby:2.5.1-alpine

RUN apk --no-cache add make gcc libc-dev

RUN mkdir /app
WORKDIR /app

ADD Gemfile /app/
ADD Gemfile.lock /app/

RUN bundle install

ADD . /app/
RUN chmod +x bin/consumer
