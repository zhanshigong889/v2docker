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

get_ip

get_envs() {
    [[ -z $NODEID ]] && NODEID=1
	[[ -z $WEBAPI ]] && WEBAPI=https://example.com/
    [[ -z $CHECK ]] && CHECK=60
	[[ -z $TOKEN ]] && TOKEN=
	[[ -z $LOCAL ]] && LOCAL=10084
	[[ -z $NODE_SPEED ]] && NODE_SPEED=0
	[[ -z $USER_COUNT ]] && USER_COUNT=0
	[[ -z $USER_SPEED ]] && USER_SPEED=0
}

get_envs

cat > /etc/config.json<< TEMPEOF
{
  "poseidon": {
	"panel": "v2board",         // 这一行必须存在，且不能更改
	"nodeId": $NODEID,          // 你的节点 ID 和 v2board 里的一致
	"checkRate": $CHECK,        // 每隔多长时间同步一次配置文件、用户、上报服务器信息
	"webapi": "$WEBAPI",        // v2board 的域名信息
	"token": "$TOKEN",          // v2board 和 v2ray-poseidon 的通信密钥
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
echo "---------- V2Ray 配置信息 -------------"
echo "节点 ID = ${NODEID}"
echo "域名信息 = ${WEBAPI}"
echo "通信密钥 = ${TOKEN}"
echo "本地端口 = ${LOCAL}"
echo "---------- END -------------"
echo

sleep 2
/usr/bin/v2ray/v2ray -config=/etc/config.json
