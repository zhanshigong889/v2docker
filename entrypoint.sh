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

    LIMIT_PORT=$PORT
    BURST=100kb
    LATENCY=50ms
    INTERVAL=60
    sleep 2

    iptables -F
    iptables -A INPUT -p tcp -m state --state NEW --dport $LIMIT_PORT -m connlimit --connlimit-above $LIMIT_CONN -j DROP
    tc qdisc add dev eth0 root tbf rate $RATE burst $BURST latency $LATENCY
    # watch -n $INTERVAL tc -s qdisc ls dev eth0

    echo
    echo "---------- V2 配置信息 -------------"
    echo "地址 (Address) = ${ip}"
    echo "端口 (Port) = $PORT"
    echo "用户ID (User ID / UUID) = ${ID}"
    echo "额外ID (Alter Id) = 233"
    echo "传输协议 (Network) = tcp"
    echo "伪装类型 (header type) = none"
    echo -e "vmess://$(cat /tmp/vmess_qr.json | base64 | xargs | sed 's/\s\+//g')"
    echo "---------- END -------------"
    echo
}

install_pos() {
    echo "install_pos"

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
