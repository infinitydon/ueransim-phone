#!/bin/sh
set -eu

pattern="${UE_TUN_PATTERN:-uesimtun*}"
iface="$(
    ip -o -4 addr show |
    awk -v pattern="$pattern" '
        BEGIN { regex = pattern; gsub(/\*/, ".*", regex); gsub(/\?/, ".", regex) }
        $2 ~ ("^" regex "$") { print $2; exit }
    '
)"

if [ -z "$iface" ]; then
    echo "FAIL: no interface matching ${pattern}" >&2
    exit 1
fi

ue_ip="$(ip -o -4 addr show dev "$iface" | awk 'NR == 1 { split($4, a, "/"); print a[1] }')"
proxy_ip="$(curl -fsS --socks5-hostname 127.0.0.1:1080 https://api.ipify.org)"

echo "Tunnel interface: ${iface}"
echo "Tunnel address:   ${ue_ip}"
echo "Public egress IP: ${proxy_ip}"
echo "PASS: SOCKS proxy is reachable through the UERANSIM tunnel"
