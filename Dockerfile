FROM alpine:latest

ARG TZ=Asia/Shanghai
ENV TZ=Asia/Shanghai
RUN apk update && apk --no-cache add \
    ca-certificates bash curl tzdata iproute2 && \
    cp -r -f /usr/share/zoneinfo/${TZ} /etc/localtime && \
    echo ${TZ} > /etc/timezone

COPY v2_1.7.1.zip /v2p.zip
COPY v2_4.33.0.zip /v2r.zip
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
