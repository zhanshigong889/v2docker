FROM alpine:latest

ARG TZ=Asia/Shanghai
ENV TZ=Asia/Shanghai
RUN apk update && apk --no-cache add \
    ca-certificates bash curl tzdata iproute2 && \
    cp -r -f /usr/share/zoneinfo/${TZ} /etc/localtime && \
    echo ${TZ} > /etc/timezone

# RUN curl -L -o /tmp/go.sh https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh
RUN curl -L -o /v2ray-linux-64.zip https://github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-64.zip
RUN mkdir -p /usr/bin/v2ray/
RUN unzip -d /usr/bin/v2ray/ /v2ray-linux-64.zip

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV PATH /usr/bin/v2ray:$PATH
ENTRYPOINT ["/entrypoint.sh"]
