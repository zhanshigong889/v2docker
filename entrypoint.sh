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


get_ip

get_envs

sleep 2
/var/v2dir/v2bin -config=/var/v2dir/config.json
