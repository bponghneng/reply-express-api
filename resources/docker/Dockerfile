FROM elixir:1.18.4-otp-27

RUN apt-get update && apt-get install --yes postgresql-client

ADD . /app

RUN mix local.hex --force \
  && mix local.rebar --force

WORKDIR /app
EXPOSE 4000
