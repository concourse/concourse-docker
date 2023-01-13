FROM ubuntu:jammy AS ubuntu

FROM ubuntu AS assets
COPY ./linux-rc/*.tgz /tmp
RUN tar xzf /tmp/*tgz -C /usr/local


FROM ubuntu

# auto-wire work dir for 'worker' and 'quickstart'
ENV CONCOURSE_WORK_DIR                /worker-state
ENV CONCOURSE_WORKER_WORK_DIR         /worker-state

# volume for non-aufs/etc. mount for baggageclaim's driver
VOLUME /worker-state

RUN apt update && apt upgrade -y -o Dpkg::Options::="--force-confdef"
RUN apt update && apt install -y \
    btrfs-progs \
    ca-certificates \
    dumb-init \
    iproute2 \
    file \
    iptables
RUN update-alternatives --set iptables /usr/sbin/iptables-legacy

COPY --from=assets /usr/local/concourse /usr/local/concourse

STOPSIGNAL SIGUSR2

COPY ./concourse-docker/entrypoint.sh /usr/local/bin
ENTRYPOINT ["dumb-init", "/usr/local/bin/entrypoint.sh"]
