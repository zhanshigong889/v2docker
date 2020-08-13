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
        [[ -z $ID ]] && ID=$(cat /proc/sys/kernel/random/uuid)
	[[ -z $PORT ]] && PORT=59028
	[[ -z $ALTER ]] && ALTER=12
	[[ -z $DOMAIN ]] && DOMAIN=
	[[ -z $REMARKS ]] && REMARKS=sanjin
	[[ -z $RATE ]] && RATE=500mbit
	[[ -z $LIMIT_CONN ]] && LIMIT_CONN=500
}

get_envs

cat > /etc/config.json<< TEMPEOF
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



LIMIT_PORT=$PORT
BURST=100kb
LATENCY=50ms
INTERVAL=60
sleep 2



echo "---------- V2Ray 配置信息 -------------"

iptables -F
iptables -A INPUT -p tcp -m state --state NEW --dport $LIMIT_PORT -m connlimit --connlimit-above $LIMIT_CONN -j DROP
tc qdisc add dev eth0 root tbf rate $RATE burst $BURST latency $LATENCY
# watch -n $INTERVAL tc -s qdisc ls dev eth0



echo
echo "---------- V2Ray 配置信息 -------------"
echo "地址 (Address) = ${ip}"
echo "端口 (Port) = $PORT"
echo "用户ID (User ID / UUID) = ${ID}"
echo "额外ID (Alter Id) = 233"
echo "传输协议 (Network) = tcp"
echo "伪装类型 (header type) = none"
echo "---------- END -------------"
echo

cat >/tmp/vmess_qr.json <<-EOF
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

url_create() {
	vmess="vmess://$(cat /tmp/vmess_qr.json | base64 | xargs | sed 's/\s\+//g')"
	echo
	echo "---------- V2Ray vmess URL / V2RayNG v0.4.1+ / V2RayN v2.1+ / 仅适合部分客户端 -------------"
	echo
	echo -e $vmess
	echo
}

url_create

rm -rf /tmp/vmess_qr.json

sleep 2
/usr/bin/v2ray/v2ray -config=/etc/config.json
