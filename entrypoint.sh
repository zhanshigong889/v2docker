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
    [[ -z $PROTOCOL ]]   && PROTOCOL=`echo dm1lc3M= | base64 -d`
    [[ -z $UUID ]]       && UUID=00000000-0000-0000-0000-000000000000
    [[ -z $PORT ]]       && PORT=8000
    [[ -z $ALTER ]]      && ALTER=3
    [[ -z $BURST ]]      && BURST=100kb
    [[ -z $LATENCY ]]    && LATENCY=50ms
    [[ -z $INTERVAL ]]   && INTERVAL=60
    [[ -z $LIMIT_PORT ]] && LIMIT_PORT=$PORT

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
    mv /var/v2dir/v2r* /var/v2dir/v2bin

    iptables -F
    iptables -A INPUT -p tcp -m state --state NEW --dport $LIMIT_PORT -m connlimit --connlimit-above $LIMIT_CONN -j DROP
    tc qdisc add dev eth0 root tbf rate $RATE burst $BURST latency $LATENCY
    # watch -n $INTERVAL tc -s qdisc ls dev eth0

    config1='ewoibG9nIjp7CiJhY2Nlc3MiOiIvZGV2L3N0ZG91dCIsCiJlcnJvciI6Ii9kZXYvc3Rkb3V0IiwKImxvZ2xldmVsIjoid2FybmluZyIKfSwKImluYm91bmQiOnsKInBvcnQiOiR7UE9SVH0sCiJwcm90b2NvbCI6IiR7UFJPVE9DT0x9IiwKInNldHRpbmdzIjp7CiJ1ZHAiOnRydWUsCiJjbGllbnRzIjpbewoiaWQiOiIke1VVSUR9Ii'
    config2='wKImFsdGVySWQiOiR7QUxURVJ9Cn1dCn0sCiJzdHJlYW1TZXR0aW5ncyI6ewoibmV0d29yayI6IndzIgp9Cn0sCiJvdXRib3VuZCI6ewoicHJvdG9jb2wiOiJmcmVlZG9tIiwKInNldHRpbmdzIjp7fQp9LAoib3V0Ym91bmREZXRvdXIiOlsKewoicHJvdG9jb2wiOiJibGFja2hvbGUiLAoic2V0dGluZ3MiOnt9LAoidGFnIjoiYmxv'
    config3='Y2tlZCIKfQpdLAoicm91dGluZyI6ewoic3RyYXRlZ3kiOiJydWxlcyIsCiJzZXR0aW5ncyI6ewoicnVsZXMiOlt7CiJ0eXBlIjoiZmllbGQiLAoiaXAiOlsKIjAuMC4wLjAvOCIsCiIxMC4wLjAuMC84IiwKIjEwMC42NC4wLjAvMTAiLAoiMTI3LjAuMC4wLzgiLAoiMTY5LjI1NC4wLjAvMTYiLAoiMTcyLjE2LjAuMC8xMiIsCiIxOT'
    config4='IuMC4wLjAvMjQiLAoiMTkyLjAuMi4wLzI0IiwKIjE5Mi4xNjguMC4wLzE2IiwKIjE5OC4xOC4wLjAvMTUiLAoiMTk4LjUxLjEwMC4wLzI0IiwKIjIwMy4wLjExMy4wLzI0IiwKIjo6MS8xMjgiLAoiZmMwMDo6LzciLAoiZmU4MDo6LzEwIgpdLAoib3V0Ym91bmRUYWciOiJibG9ja2VkIgp9XQp9Cn0KfQ=='
    echo $config1$config2$config3$config4 | base64 -d | sed "s/\${PORT}/${PORT}/g" | sed "s/\${PROTOCOL}/${PROTOCOL}/g" | sed "s/\${UUID}/${UUID}/g" | sed "s/\${ALTER}/${ALTER}/g" > /var/v2dir/config.json

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
    echo "端口 (Port) = ${PORT}"
    echo "用户ID (User ID / UUID) = ${UUID}"
    echo "额外ID (Alter Id) = ${ALTER}"
    echo "传输协议 (Network) = tcp"
    echo "伪装类型 (header type) = none"
    echo -e "${PROTOCOL}://$(cat /tmp/qr.json | base64 | xargs | sed 's/\s\+//g')"
    echo "---------- END -------------"
    echo
}

install_pos() {
    echo "install_pos"

    mkdir /var/v2dir
    unzip -d /var/v2dir/ /v2p.zip
    mv /var/v2dir/v2r* /var/v2dir/v2bin

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

echo "正在启动 ${BIN_TYPE}"
if [ x${BIN_TYPE} == "xray" ]
then
    install_ray
elif [ x${BIN_TYPE} == "xpos" ]
then
    install_pos
else
    echo "unknow"
fi

sleep 2
/var/v2dir/v2bin -config=/var/v2dir/config.json
