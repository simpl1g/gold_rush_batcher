FROM ruby:2.5.1-alpine

RUN mkdir /app
WORKDIR /app

RUN gem install rack
ADD netcat.ru /app/

