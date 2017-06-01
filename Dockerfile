FROM ubuntu:16.04

RUN apt-get update && apt-get -y install iproute2 ca-certificates

ADD bin/dumb-init /usr/local/bin
ADD bin/concourse /usr/local/bin

# volume containing keys to use
VOLUME /concourse-keys

# 'web' keys
ENV CONCOURSE_TSA_HOST_KEY        /concourse-keys/host_key
ENV CONCOURSE_TSA_AUTHORIZED_KEYS /concourse-keys/authorized_worker_keys
ENV CONCOURSE_SESSION_SIGNING_KEY /concourse-keys/session_signing_key

# 'worker' keys
ENV CONCOURSE_TSA_PUBLIC_KEY         /concourse-keys/host_key.pub
ENV CONCOURSE_TSA_WORKER_PRIVATE_KEY /concourse-keys/worker_key

# volume for non-aufs/etc. mount for baggageclaim's driver
VOLUME /worker-state
ENV CONCOURSE_WORK_DIR /worker-state

# enable DNS proxy to support Docker's 127.x.x.x DNS server
ENV CONCOURSE_GARDEN_DNS_PROXY_ENABLE true

ENTRYPOINT ["/usr/local/bin/dumb-init", "/usr/local/bin/concourse"]
