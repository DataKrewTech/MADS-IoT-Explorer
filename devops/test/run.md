## Test Run Setup

Make sure you have the local postgres server running at port 5432

### Tool Requirements
- docker
- docker-compose

### Technical Requirements
- Elixir 1.11
- Erlang OTP 23

After setting above language requirements, make sure you run the following commands by being
in the project root directory

```
rm -rf _build
mix local.rebar    [incase if you are having trouble with compiling libraries]
mix deps.clean --all
mix deps.get
```

### Running Kafka Docker
- GOTO `devops/local/kafka_docker`
- RUN `docker-compose up`

### Environmental Variables Setup
- GOTO `env` folder | Command: `cd env`
- CREATE `local.env` file | Command: `touch local.env`
- COPY `example.env` into `local.env` | Command: `cp example.env local.env`
- EDIT `local.env` with following Environmental Variables
  ```
  export DB_USER=postgres
  export DB_PASSWORD=postgres
  export DB_HOST=database
  export DB_PORT=5432
  export MQTT_HOST=localhost
  export MQTT_PORT=1882
  ```
## Application Startup
The application at present consists of the following services:

- `web_app`
  The main web app consists of three apps:
  - api_app
  - iot_app
  - core
- `database`
  The database backing the web service, it consists of the following:
  - postgres with timescaledb extension
- `elastic_search`
  Elastic search for performing search and aggregations.
  For local development, there is just one node.

## Start the cluster

To start the application run the following steps:

- RUN `source env/local.env`
- GOTO`devops/test` directory
- Start the cluster
  - Run `docker-compose up --build` to run in foreground. If environment is not taking variables then use 
    `sudo -E docker-compose up --build`
  - Run `docker-compose up --build -d`, to run it as a daemon.
- The above command builds the application, creates releases and runs migrations.
- The `api_app` is available at `localhost:4000` and the `iot_app` at `localhost:4001`
- The containers started by apps are with following names:
  - `web_app`
  - `es01`
  - `local_database_{number}`
- To seed the application run the command
  `docker container exec -it web_app /home/app/prod/rel/web_and_iot/bin/web_and_iot eval AcqdatCore.ReleaseTasks.seed`

###Note
If you get any error like `DB_HOST` environment variables then please run the command as `sudo -E docker-compose up --build`

### Stop Containers and Clean Volumes

- To stop the containers clear up RUN `docker-compose down`.
- To stop the contianers and clear up along with **volumes** run `docker-compose down -v`

### Note

In `docker-compose up --build` you only need to this if you want the code to be built
again. This is usually needed if you have pulled some new changes to branch or
you have switched to a new branch.
Normally once the build has been run the first time, you will be able to start
the app with `docker-compose up -d` or `docker-compose up` afterwards.

If you have **containers already running, please stop and clear** before running them
again or it will lead to unexpected behaviour.

Remove the volumes only if you need to seed the database again or you want to
reinitialize with a fresh slate.
