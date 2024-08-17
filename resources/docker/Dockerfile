FROM elixir:1.17.2

RUN apt-get update && apt-get install --yes postgresql-client

ADD . /app

RUN mix local.hex --force \
  && mix local.rebar --force

WORKDIR /app
EXPOSE 4000
CMD ["./run.sh"]
