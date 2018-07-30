# Concourse Docker

This Docker image simply packages up the official `concourse` binary and
configures it as the `ENTRYPOINT`, with a bunch of sane defaults for Docker.

Configuration is done via `CONCOURSE_*` environment variables. To discover
them, run `--help`:

```sh
docker run concourse/concourse --help
docker run concourse/concourse web --help
docker run concourse/concourse worker --help
```

See [the `concourse` binary docs](https://concourse-ci.org/install.html) for
more information - the instructions and requirements are the same. For network
and hardware resources reference, see [Deployment
Topology](https://concourse-ci.org/topology.html).


## Docker Compose

There are two Docker Compose `.yml` files in this repo. The first one,
`docker-compose.yml`, runs a more traditional multi-container cluster. You'll
need to run `./generate-keys.sh` before booting up, so that the containers know
how to authorize each other.

The `docker-compose-quickstart.yml` file can be used to quickly get up and
running with the `concourse quickstart` command. No keys need to be generated
in this case.

When running the Docker Compose `.yml` files, you will need to make sure you configure the authorization environment variables. If you want to run the Concourse web node with no authroziation, make sure to set `CONCOURSE_NO_REALLY_I_DONT_WANT_ANY_AUTH=true`.

## Docker Run

Alternatively, these two Docker Run commands can be used to get `concourse-quickstart` up and running with 2 containers.  These command provide not only `concourse`, but also a database instance for it to use. 

docker network create concourse-net

docker run --name concourse-db \
  --net=concourse-net \
  -h concourse-postgres \
  -p 5432:5432 \
  -e POSTGRES_USER=<PG USER> \
  -e POSTGRES_PASSWORD=<PG P ASSWORD> \
  -e POSTGRES_DB=atc \
  -d postgres

docker run  --name concourse \
  -h concourse \
  -p 8080:8080 \
  --privileged \
  --net=concourse-net \
  concourse/concourse quickstart \
  --basic-auth-username=<CONCOURSE USER> \
  --basic-auth-password=<CONCOURSE PASSWORD> \
  --postgres-user=<PG USER> \
  --postgres-password=<PG PASSWORD> \
  --postgres-host=concourse-db \
  --worker-garden-dns-server 8.8.8.8

## Caveats

At the moment, workers running via Docker will not automatically leave the
cluster gracefully on shutdown. This means you'll have to run [`fly
prune-worker`](https://concourse-ci.org/administration.html#fly-prune-worker)
to reap them.

This will be resolved with [concourse/concourse
#1457](https://github.com/concourse/concourse/issues/1457).
