FROM elixir:1.9.1-alpine AS plugin_builder

# Set environment variables for building the application    
ARG DB_HOST
ARG DB_PORT
ARG DB_USER
ARG DB_PASSWORD
ENV MIX_ENV=prod \
    TEST=1 \
    LANG=C.UTF-88 \
    DB_HOST=${DB_HOST} \
    DB_PORT=${DB_PORT} \
    DB_USER=${DB_USER} \
    DB_PASSWORD=${DB_PASSWORD}

RUN apk add build-base

RUN apk add --update git && \
    rm -rf /var/cache/apk/*

# Install hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Create the application build directory
RUN mkdir /app
WORKDIR /app

ADD http://api.geonames.org/timezoneJSON?formatted=true&lat=47.01&lng=10.2&username=demo&style=full /tmp/bustcache

# Copy over all the necessary application files and directories
# for umbrella
COPY mix.exs .
COPY mix.lock .
COPY config ./config
COPY rel ./rel

# create child app directories
RUN mkdir -p \
    apps/vernemq_mads_plugin/

COPY apps/vernemq_mads_plugin/ apps/vernemq_mads_plugin/
WORKDIR /app/apps/vernemq_mads_plugin/

RUN mix deps.get
RUN mix deps.compile
RUN mix release

FROM vernemq/vernemq:latest-alpine

WORKDIR /home/app

COPY --from=plugin_builder /app/_build .

COPY devops/test/mqtt/vernemq.conf /etc/vernemq/
