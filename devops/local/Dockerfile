# It's a multi stage build where the app is first compiled
# in the target OS and then to keep the image size minimum
# only release files are copied to the new image.

# FROM based elixir-1.9.1-alpine image
FROM elixir:1.9.1-alpine AS app_builder

# Set environment variables for building the application
ENV MIX_ENV=prod \
    TEST=1 \
    LANG=C.UTF-8

RUN apk add build-base

#install git and remove cache
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
  apps/acqdat_api/ \
  apps/acqdat_core/ \
  apps/acqdat_iot/ \
  apps/virta/

# copy child directory artifacts to respective app directories
COPY apps/acqdat_api/ apps/acqdat_api/
COPY apps/acqdat_core/ apps/acqdat_core/
COPY apps/acqdat_iot/ apps/acqdat_iot/
COPY apps/virta/ apps/virta/

# Fetch the application dependencies and build the application
RUN mix deps.get
RUN mix deps.compile
RUN mix release

# ---- Application Stage ----
FROM alpine AS app

ENV LANG=C.UTF-8

# Install openssl
RUN apk add --update openssl ncurses-libs postgresql-client && \
    rm -rf /var/cache/apk/*

# Copy over the build artifact from the previous step and create a non root user
RUN adduser -D -h /home/app app
WORKDIR /home/app
COPY --from=app_builder /app/_build .
RUN chown -R app: ./prod
USER app

COPY entrypoint.sh .

# Run entrypoint.sh
CMD ["./entrypoint.sh"]
