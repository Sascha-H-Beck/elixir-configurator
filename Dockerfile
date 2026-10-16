ARG ELIXIR_VERSION=1.18.4
ARG OTP_VERSION=27.3.4
ARG DEBIAN_VERSION=bullseye-20260112-slim

FROM hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION} AS build

RUN apt-get update -y && apt-get install -y build-essential git curl
WORKDIR /app

RUN mix local.hex --force && mix local.rebar --force
ENV MIX_ENV=prod

COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

COPY assets assets
RUN cd assets && npm install && cd ..

COPY priv priv
COPY lib lib
RUN mix compile
RUN mix assets.setup
RUN mix assets.deploy

COPY config/runtime.exs config/
RUN mix release

FROM debian:${DEBIAN_VERSION} AS app

RUN apt-get update -y && apt-get install -y libstdc++6 openssl libncurses5 locales \
  && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

WORKDIR /app

RUN groupadd --gid 1000 appuser && useradd --uid 1000 --gid appuser --shell /bin/bash --create-home appuser

COPY --from=build --chown=appuser:appuser /app/_build/prod/rel/elixirmachine ./
COPY --from=build --chown=appuser:appuser /app/priv/static ./priv/static

USER appuser
EXPOSE 4000
ENV PHX_SERVER=true
ENV PORT=4000

CMD ["sh", "-c", "bin/elixirmachine eval Elixirmachine.Release.migrate && bin/elixirmachine start"]
