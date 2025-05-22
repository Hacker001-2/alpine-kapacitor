# syntax=docker/dockerfile:1
#
ARG IMAGEBASE=frommakefile
#
FROM ${IMAGEBASE}
#
ARG SRCARCH
ARG VERSION
#
ENV \
    KAPACITOR_URL=http://localhost:9092 \
    KAPACITOR_CONFIG=/etc/kapacitor/kapacitor.conf
#
RUN set -xe \
    && apk add -Uu --purge --no-cache \
        ca-certificates \
        curl \
    && update-ca-certificates \
    && curl \
        -o /tmp/kapacitor.tar.gz \
        -jSLN https://dl.influxdata.com/kapacitor/releases/kapacitor-${VERSION}_${SRCARCH}.tar.gz \
    && tar xzf /tmp/kapacitor.tar.gz -C / --strip 2 \
    && mkdir -p /defaults \
    && mv /etc/kapacitor/kapacitor.conf /defaults/kapacitor.conf.default \
    && chmod +x \
        /usr/bin/kapacitord \
        /usr/bin/kapacitor \
#
    && apk del --purge curl \
    && rm -rf /var/cache/apk/* /tmp/*
#
COPY root/ /
#
VOLUME  ["/var/lib/kapacitor"]
#
EXPOSE 9092
#
HEALTHCHECK \
    --interval=2m \
    --retries=5 \
    --start-period=5m \
    --timeout=10s \
    CMD \
    wget --quiet --tries=1 --no-check-certificate -O - ${HEALTHCHECK_URL:-"http://localhost:9092/kapacitor/v1/ping"} \
    | grep -q "HTTP/1.1 204 No Content" \
    || exit 1
#
ENTRYPOINT ["/init"]
