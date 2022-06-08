#!/bin/sh

[ "${CONCOURSE_RUNTIME}" = "containerd" ] || [ "${CONCOURSE_WORKER_RUNTIME}" = "containerd" ] && \
[ "$(mount | grep ' /sys/fs/cgroup ' | grep -c cgroup2)" -eq 1 ] && \
mkdir /sys/fs/cgroup/entrypoint && \
echo 1 > /sys/fs/cgroup/entrypoint/cgroup.procs

CONCOURSE_SESSION_SIGNING_KEY=${CONCOURSE_SESSION_SIGNING_KEY:-/concourse-keys/session_signing_key}
[ -f "$CONCOURSE_SESSION_SIGNING_KEY" ] && export CONCOURSE_SESSION_SIGNING_KEY
CONCOURSE_TSA_AUTHORIZED_KEYS=${CONCOURSE_TSA_AUTHORIZED_KEYS:-/concourse-keys/authorized_worker_keys}
[ -f "$CONCOURSE_TSA_AUTHORIZED_KEYS" ] && export CONCOURSE_TSA_AUTHORIZED_KEYS
CONCOURSE_TSA_HOST_KEY=${CONCOURSE_TSA_HOST_KEY:-/concourse-keys/tsa_host_key}
[ -f "$CONCOURSE_TSA_HOST_KEY" ] && export CONCOURSE_TSA_HOST_KEY
CONCOURSE_TSA_PUBLIC_KEY=${CONCOURSE_TSA_PUBLIC_KEY:-/concourse-keys/tsa_host_key.pub}
[ -f "$CONCOURSE_TSA_PUBLIC_KEY" ] && export CONCOURSE_TSA_PUBLIC_KEY
CONCOURSE_TSA_WORKER_PRIVATE_KEY=${CONCOURSE_TSA_WORKER_PRIVATE_KEY:-/concourse-keys/worker_key}
[ -f "$CONCOURSE_TSA_WORKER_PRIVATE_KEY" ] && export CONCOURSE_TSA_WORKER_PRIVATE_KEY
[ -f "$CONCOURSE_POSTGRES_PASSWORD_FILE" ] && export CONCOURSE_POSTGRES_PASSWORD=$(cat "$CONCOURSE_POSTGRES_PASSWORD_FILE")
exec /usr/local/concourse/bin/concourse "$@"
