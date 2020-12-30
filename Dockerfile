FROM alpine:latest

ARG TZ=Asia/Shanghai
ENV TZ=Asia/Shanghai
RUN apk update && apk --no-cache add \
    ca-certificates bash curl tzdata iproute2 && \
    cp -r -f /usr/share/zoneinfo/${TZ} /etc/localtime && \
    echo ${TZ} > /etc/timezone

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
