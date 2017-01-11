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

# directory to keep worker state; can be bind-mounted over
ENV CONCOURSE_WORK_DIR /worker-state

ENTRYPOINT ["/usr/local/bin/dumb-init", "/usr/local/bin/concourse"]
