FROM alpine:latest

ARG TZ=Asia/Shanghai
ENV TZ=Asia/Shanghai
RUN apk update && apk --no-cache add \
    ca-certificates bash curl tzdata iproute2 && \
    cp -r -f /usr/share/zoneinfo/${TZ} /etc/localtime && \
    echo ${TZ} > /etc/timezone

RUN curl -L -o /tmp/go.sh https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh
RUN mkdir -p /usr/bin/v2ray
RUN chmod +x /tmp/go.sh
RUN /tmp/go.sh

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV PATH /usr/bin/v2ray:$PATH
ENTRYPOINT ["/entrypoint.sh"]
