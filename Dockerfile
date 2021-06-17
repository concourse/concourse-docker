FROM ubuntu:focal AS ubuntu

FROM ubuntu AS assets
COPY ./linux-rc/*.tgz /tmp
RUN tar xzf /tmp/*tgz -C /usr/local


FROM ubuntu

# auto-wire work dir for 'worker' and 'quickstart'
ENV CONCOURSE_WORK_DIR                /worker-state
ENV CONCOURSE_WORKER_WORK_DIR         /worker-state

# volume for non-aufs/etc. mount for baggageclaim's driver
VOLUME /worker-state

RUN apt-get update && apt-get install -y \
    btrfs-tools \
    ca-certificates \
    dumb-init \
    iproute2 \
    file \
    iptables

COPY --from=assets /usr/local/concourse /usr/local/concourse

STOPSIGNAL SIGUSR2

COPY ./concourse-docker/entrypoint.sh /usr/local/bin
ENTRYPOINT ["dumb-init", "/usr/local/bin/entrypoint.sh"]
