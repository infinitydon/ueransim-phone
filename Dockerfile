FROM docker.io/alpine:3.22.1

RUN apk add --no-cache curl dante-server iproute2

COPY rootfs/usr/local/bin/ue-socks /usr/local/bin/ue-socks
COPY tests/verify-tunnel.sh /usr/local/bin/verify-ue-path
RUN chmod 755 /usr/local/bin/ue-socks /usr/local/bin/verify-ue-path

USER 0
ENTRYPOINT ["/usr/local/bin/ue-socks"]

LABEL org.opencontainers.image.title="UERANSIM Phone Egress Proxy" \
      org.opencontainers.image.description="Fail-closed SOCKS5 proxy bound to a UERANSIM tunnel" \
      org.opencontainers.image.source="https://github.com/infinitydon/ueransim-phone" \
      org.opencontainers.image.version="0.2.1"
