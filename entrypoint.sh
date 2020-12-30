#!/bin/sh

get_ip() {
    ip=$DOMAIN
    [[ -z $ip ]] && ip=$(curl -s https://ipinfo.io/ip)
    [[ -z $ip ]] && ip=$(curl -s https://api.ip.sb/ip)
    [[ -z $ip ]] && ip=$(curl -s https://api.ipify.org)
    [[ -z $ip ]] && ip=$(curl -s https://ip.seeip.org)
    [[ -z $ip ]] && ip=$(curl -s https://ifconfig.co/ip)
    [[ -z $ip ]] && ip=$(curl -s https://api.myip.com | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}")
    [[ -z $ip ]] && ip=$(curl -s icanhazip.com)
    [[ -z $ip ]] && ip=$(curl -s myip.ipip.net | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}")
    [[ -z $ip ]] && echo -e "\n$red 这垃圾小鸡扔了吧！$none\n" && exit
}

get_envs() {
    [[ -z $NODEID ]] && NODEID=1
    [[ -z $WEBAPI ]] && WEBAPI=https://example.com/
    [[ -z $CHECK ]]  && CHECK=60
    [[ -z $TOKEN ]]  && TOKEN=
    [[ -z $LOCAL ]]  && LOCAL=10084
    [[ -z $NODE_SPEED ]] && NODE_SPEED=0
    [[ -z $USER_COUNT ]] && USER_COUNT=0
    [[ -z $USER_SPEED ]] && USER_SPEED=0
}

install_ray() {
    echo "install_ray"

    mkdir /var/v2dir
    unzip -d /var/v2dir/ /v2r.zip
    mv v2r* v2bin

    LIMIT_PORT=$PORT
    BURST=100kb
    LATENCY=50ms
    INTERVAL=60
    sleep 2

    iptables -F
    iptables -A INPUT -p tcp -m state --state NEW --dport $LIMIT_PORT -m connlimit --connlimit-above $LIMIT_CONN -j DROP
    tc qdisc add dev eth0 root tbf rate $RATE burst $BURST latency $LATENCY
    # watch -n $INTERVAL tc -s qdisc ls dev eth0

    cat > /var/v2dir/config.json<< TEMPEOF
{
    "log": {
        "access": "/dev/stdout",
        "error": "/dev/stdout",
        "loglevel": "warning"
    },
    "inbound": {
        "port": $PORT,
        "protocol": "vmess",
        "settings": {
            "udp": true,
            "clients": [
                {
                    "id": "$ID",
                    "level": 1,
                    "alterId": $ALTER
                }
            ]
        },
        "streamSettings": {
            "network": "ws"
        }
    },
    "outbound": {
        "protocol": "freedom",
        "settings": {}
    },
    "outboundDetour": [
        {
            "protocol": "blackhole",
            "settings": {},
            "tag": "blocked"
        }
    ],
    "routing": {
        "strategy": "rules",
        "settings": {
            "rules": [
                {
                    "type": "field",
                    "ip": [
                        "0.0.0.0/8",
                        "10.0.0.0/8",
                        "100.64.0.0/10",
                        "127.0.0.0/8",
                        "169.254.0.0/16",
                        "172.16.0.0/12",
                        "192.0.0.0/24",
                        "192.0.2.0/24",
                        "192.168.0.0/16",
                        "198.18.0.0/15",
                        "198.51.100.0/24",
                        "203.0.113.0/24",
                        "::1/128",
                        "fc00::/7",
                        "fe80::/10"
                    ],
                    "outboundTag": "blocked"
                }
            ]
        }
    }
}
TEMPEOF

    cat >/tmp/qr.json <<-EOF
{
    "v": "2",
    "ps": "${REMARKS}",
    "add": "${ip}",
    "port": "${PORT}",
    "id": "${ID}",
    "aid": "${ALTER}",
    "net": "ws",
    "type": "none",
    "host": "",
    "path": "",
    "tls": ""
}
EOF

    echo
    echo "---------- V2 配置信息 -------------"
    echo "地址 (Address) = ${ip}"
    echo "端口 (Port) = $PORT"
    echo "用户ID (User ID / UUID) = ${ID}"
    echo "额外ID (Alter Id) = 233"
    echo "传输协议 (Network) = tcp"
    echo "伪装类型 (header type) = none"
    echo -e "://$(cat /tmp/qr.json | base64 | xargs | sed 's/\s\+//g')"
    echo "---------- END -------------"
    echo
}

install_pos() {
    echo "install_pos"

    mkdir /var/v2dir
    unzip -d /var/v2dir/ /v2p.zip
    mv v2r* v2bin

    cat > /var/v2dir/config.json<< TEMPEOF
{
  "poseidon": {
    "panel": "v2board",         // 这一行必须存在，且不能更改
    "nodeId": $NODEID,          // 你的节点 ID 和 v2board 里的一致
    "checkRate": $CHECK,        // 每隔多长时间同步一次配置文件、用户、上报服务器信息
    "webapi": "$WEBAPI",        // v2board 的域名信息
    "token": "$TOKEN",          // v2board 和 poseidon 的通信密钥
    "speedLimit": $NODE_SPEED,  // 节点限速 单位 字节/s 0 表示不限速
    "user": {
      "maxOnlineIPCount": $USER_COUNT, // 用户同时在线 IP 数限制 0 表示不限制
      "speedLimit": $USER_SPEED        // 用户限速 单位 字节/s 0 表示不限速
    },
    "localPort": $LOCAL          // 本地 api, dokodemo-door,　监听在哪个端口，不能和服务端口相同
  }
}
TEMPEOF

    echo
    echo "---------- V2 配置信息 -------------"
    echo "节点 ID = ${NODEID}"
    echo "域名信息 = ${WEBAPI}"
    echo "通信密钥 = ${TOKEN}"
    echo "本地端口 = ${LOCAL}"
    echo "---------- END -------------"
    echo
}

get_ip

get_envs

install_start

if [ x$1 == "xray" ]
then
    install_ray
elif [ x$1 == "xpos" ]
then
    install_pos
else
    echo "null"
fi

sleep 2
/var/v2dir/v2bin -config=/var/v2dir/config.json
