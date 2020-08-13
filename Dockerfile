############################
# STEP 1 build executable binary
############################
FROM golang:alpine AS builder
RUN apk update && apk add --no-cache git bash wget curl
WORKDIR /go/src/v2ray.com/core
RUN git clone --progress https://github.com/v2fly/v2ray-core.git . && \
    bash ./release/user-package.sh nosource noconf codename=$(git describe --tags) buildname=docker-fly abpathtgz=/tmp/v2ray.tgz
############################
# STEP 2 build a small image
############################
FROM alpine

LABEL maintainer "V2Fly Community <admin@v2fly.org>"
COPY --from=builder /tmp/v2ray.tgz /tmp
RUN apk update && apk add ca-certificates && \
    mkdir -p /usr/bin/v2ray && \
    tar xvfz /tmp/v2ray.tgz -C /usr/bin/v2ray

RUN apk add -U iproute2 tzdata curl && ln -s /usr/lib/tc /lib/tc \
    && cp -r -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

#ENTRYPOINT ["/usr/bin/v2ray/v2ray"]
ENV PATH /usr/bin/v2ray:$PATH
ENTRYPOINT ["/entrypoint.sh"]
