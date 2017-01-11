#!/usr/bin/env bash

set -e -u -x

mkdir -p keys/web keys/worker

yes | ssh-keygen -t rsa -f ./keys/web/host_key -N ''
yes | ssh-keygen -t rsa -f ./keys/web/session_signing_key -N ''

yes | ssh-keygen -t rsa -f ./keys/worker/worker_key -N ''

cp ./keys/worker/worker_key.pub ./keys/web/authorized_worker_keys
cp ./keys/web/host_key.pub ./keys/worker
