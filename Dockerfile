ARG base_image=cgr.dev/chainguard/wolfi-base

ARG BUILDPLATFORM
FROM --platform=${BUILDPLATFORM} ${base_image} AS assets
ARG TARGETARCH
COPY ./linux-${TARGETARCH}/*.${TARGETARCH}.tgz /tmp
RUN tar xzf /tmp/*tgz -C /usr/local

FROM ${base_image}

# auto-wire work dir for 'worker' and 'quickstart'
ENV CONCOURSE_WORK_DIR                /worker-state
ENV CONCOURSE_WORKER_WORK_DIR         /worker-state

# volume for non-aufs/etc. mount for baggageclaim's driver
VOLUME /worker-state

RUN apk --no-cache add \
    btrfs-progs \
    ca-certificates \
    dumb-init \
    iproute2 \
    file \
    iptables \
    ip6tables

COPY --from=assets /usr/local/concourse /usr/local/concourse

STOPSIGNAL SIGUSR2

COPY ./concourse-docker/entrypoint.sh /usr/local/bin/
ENTRYPOINT ["dumb-init", "/usr/local/bin/entrypoint.sh"]
