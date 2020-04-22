## Starting the Application

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
- Move to `env/` directory.
- Create a `local.env` file, copy keys from example.env. and set their values.
- Run `source local.env` from the same directory.
- Move to `devops/local`
- Start the cluster 
  - Run `docker-compose up --build` to run in foreground.
  - Run `docker-compose up --build -d`, to run it as a daemon.
- The above command builds the application, creates releases and runs migrations.
- The `api_app` is available at `localhost:4000` and the `iot_app` at `localhost:4001`  
- The containers started by apps are with following names:
    - `web_app`
    - `es01`
    - `local_database_{number}`
- To seed the application run the command
`docker container exec -it web_app /home/app/prod/rel/web_and_iot/bin/web_and_iot eval AcqdatCore.ReleaseTasks.seed`

### Stop Containers and Clear
- To stop the containers clear up run `docker-compose down`.
- To stop the contianers and clear up along with __volumes__ run `docker-compose down -v`


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
