FROM docker.io/jlesage/firefox:v26.07.2

USER 0

RUN apk add --no-cache dante-server iproute2

COPY rootfs/ /

RUN chmod 755 /etc/services.d/ue-socks/run /etc/services.d/ue-socks/finish

ENV DISPLAY_WIDTH=390 \
    DISPLAY_HEIGHT=844 \
    KEEP_APP_RUNNING=1 \
    DARK_MODE=1 \
    WEB_AUDIO=1 \
    WEB_FILE_MANAGER=0 \
    WEB_TERMINAL=0 \
    FF_OPEN_URL=https://example.com \
    FF_PREF_PROXY_TYPE=network.proxy.type=1 \
    FF_PREF_SOCKS_HOST=network.proxy.socks=\"127.0.0.1\" \
    FF_PREF_SOCKS_PORT=network.proxy.socks_port=1080 \
    FF_PREF_SOCKS_VERSION=network.proxy.socks_version=5 \
    FF_PREF_SOCKS_DNS=network.proxy.socks_remote_dns=true \
    FF_PREF_NO_PROXY=network.proxy.no_proxies_on=\"localhost,127.0.0.1\"

LABEL org.opencontainers.image.title="UERANSIM Phone Browser" \
      org.opencontainers.image.description="Firefox web UI whose browsing traffic exits through a UERANSIM tunnel" \
      org.opencontainers.image.source="https://github.com/infinitydon/ueransim-phone" \
      org.opencontainers.image.version="0.1.0"
