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
how to authorize each other. On systems with OpenSSH >= 7.8, you may need to
run `./generate-keys.sh --use-pem` to generate the keys using the correct
format.

The `docker-compose-quickstart.yml` file can be used to quickly get up and
running with the `concourse quickstart` command. No keys need to be generated
in this case.

Both Docker Compose files configure a `test` user with `test` as their
password, and grants every user access to the `main` team. To use this in
production you'll definitely want to change that - see [Configuring Auth
Providers](https://concourse-ci.org/install.html#auth-config) for more
information..

## Docker Run

Alternatively, these two Docker Run commands can be used to get `concourse-quickstart` up and running with 2 containers.  These command provide not only `concourse`, but also a database instance for it to use.

```
docker network create concourse-net
```

```
docker pull postgres
docker run --name concourse-db \
  --net=concourse-net \
  -h concourse-postgres \
  -p 5432:5432 \
  -e POSTGRES_USER=<PG USER> \
  -e POSTGRES_PASSWORD=<PG P ASSWORD> \
  -e POSTGRES_DB=atc \
  -d postgres
  ```

```
docker pull concourse/concourse
docker run  --name concourse \
  -h concourse \
  -p 8080:8080 \
  --detach \
  --privileged \
  --net=concourse-net \
  concourse/concourse quickstart \
  --add-local-user=<CONCOURSE_USER>:<CONCOURSE_PASSWORD> \
  --main-team-local-user=<CONCOURSE_USER> \
  --external-url=http://<DOCKER_MACHINE_IP>:8080 \
  --postgres-user=<PG_USER> \
  --postgres-password=<PG_PASSWORD> \
  --postgres-host=concourse-db \
  --worker-garden-dns-server 8.8.8.8
```

## Caveats

At the moment, workers running via Docker will not automatically leave the
cluster gracefully on shutdown. This can mean your pipelines get into a bad
state when you restart the cluster, as they'll keep trying to use the old
worker.

For now you'll have to run [`fly
prune-worker`](https://concourse-ci.org/administration.html#fly-prune-worker)
to reap any stalled workers when your cluster gets into this state.

This will be resolved with [concourse/concourse
#1457](https://github.com/concourse/concourse/issues/1457).
