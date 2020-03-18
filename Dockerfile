FROM elixir:alpine AS app_builder

ENV MIX_ENV=prod \
    LANG=C.UTF-8

RUN apk add --update git && rm -rf /var/cache/apk/*
RUN apk add make alpine-sdk

RUN mix local.hex --force && \
    mix local.rebar --force

RUN mkdir /app
WORKDIR /app

COPY config ./config
COPY lib ./lib
COPY priv ./priv
COPY mix.exs .
COPY mix.lock .

RUN mix deps.get
RUN mix deps.compile
RUN mix release

FROM alpine AS app

ENV LANG=C.UTF-8

RUN apk add --update openssl ncurses-libs postgresql-client && \
    rm -rf /var/cache/apk/*

RUN adduser -D -h /home/app app
WORKDIR /home/app
COPY --from=app_builder /app/_build .
RUN chown -R app: ./prod
USER app

COPY entrypoint.sh .

CMD ["./entrypoint.sh"]
