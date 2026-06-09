#!/bin/bash

set -e

echo "================================="
echo " GeoIP Firewall Guard"
echo "================================="
echo

read -rp "Enter ports to protect (example: 2053,8443): " PORTS
read -rp "Enter countries to block (example: ru,pk,iq): " COUNTRIES

IFS=',' read -ra PORT_ARRAY <<< "$PORTS"
IFS=',' read -ra COUNTRY_ARRAY <<< "$COUNTRIES"

echo
echo "[*] Installing dependencies..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y ipset iptables-persistent wget curl

echo
echo "[*] Preparing ipset..."

if ipset list blocked_countries >/dev/null 2>&1; then
ipset flush blocked_countries
else
ipset create blocked_countries hash:net
fi

echo
echo "[*] Configuring firewall rules..."

for PORT in "${PORT_ARRAY[@]}"; do
PORT=$(echo "$PORT" | xargs)

```
if ! iptables -C INPUT -p tcp --dport "$PORT" -m set --match-set blocked_countries src -j DROP 2>/dev/null; then
    iptables -I INPUT -p tcp --dport "$PORT" -m set --match-set blocked_countries src -j DROP
    echo "  Added protection for port $PORT"
else
    echo "  Port $PORT already protected"
fi
```

done

mkdir -p /etc/ipset

echo
echo "[*] Downloading GeoIP lists..."

for COUNTRY in "${COUNTRY_ARRAY[@]}"; do

```
COUNTRY=$(echo "$COUNTRY" | tr '[:upper:]' '[:lower:]' | xargs)

echo "  Loading $COUNTRY..."

URL="https://www.ipdeny.com/ipblocks/data/countries/${COUNTRY}.zone"
FILE="/etc/ipset/${COUNTRY}.zone"

if ! wget -q -O "$FILE" "$URL"; then
    echo "  Failed to download $COUNTRY"
    continue
fi

while IFS= read -r NET; do
    [ -z "$NET" ] && continue
    ipset add blocked_countries "$NET" -exist
done < "$FILE"
```

done

echo
echo "[*] Saving configuration..."

mkdir -p /etc/ipset

ipset save blocked_countries > /etc/ipset/blocked_countries.save

iptables-save > /etc/iptables/rules.v4

echo
echo "================================="
echo " Setup Complete"
echo "================================="
echo "Blocked countries: $COUNTRIES"
echo "Protected ports : $PORTS"
echo
echo "Verify:"
echo "  ipset list blocked_countries"
echo "  iptables -L INPUT -n --line-numbers"
echo
