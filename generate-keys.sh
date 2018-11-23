#!/usr/bin/env bash

set -e -u -x

# check if we should use the old PEM style for generating the keys
# --------
# check: https://www.openssh.com/txt/release-7.8

PEM_OPTION=

if [ "$#" -eq 1 ] && [ "$1" == '--use-pem' ]; then
    PEM_OPTION='-m PEM'
elif [ "$#" -eq 1 ]; then
    echo "Invalid argument '$1', did you mean '--use-pem'?"
    exit 1
fi

# generate the keys
# --------

mkdir -p keys/web keys/worker

yes | ssh-keygen $PEM_OPTION -t rsa -f ./keys/web/tsa_host_key -N ''
yes | ssh-keygen $PEM_OPTION -t rsa -f ./keys/web/session_signing_key -N ''

yes | ssh-keygen $PEM_OPTION -t rsa -f ./keys/worker/worker_key -N ''

cp ./keys/worker/worker_key.pub ./keys/web/authorized_worker_keys
cp ./keys/web/tsa_host_key.pub ./keys/worker

