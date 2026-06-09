#!/bin/bash
echo "================================="
echo " GeoIP Firewall Guard"
echo "================================="

# Dependencies
apt update
apt install -y ipset iptables-persistent wget curl netcat-openbsd

# Force terminal input (works with curl | bash)
exec < /dev/tty

# Input
read -rp "Enter ports to protect (e.g. 2053,8443): " PORTS
read -rp "Enter countries to block (e.g. ru,pk,iq): " COUNTRIES

# Clean input
PORTS=$(echo "$PORTS" | tr -d '[:space:]')
COUNTRIES=$(echo "$COUNTRIES" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')

# Create ipset
ipset create blocked_countries hash:net -exist
ipset flush blocked_countries

echo "[*] Loading GeoIP data..."

for c in $(echo "$COUNTRIES" | tr ',' ' '); do
    echo "---------------------------------"
    echo "[*] Downloading country: $c"

    curl -sSL "https://www.ipdeny.com/ipblocks/data/countries/${c}.zone" | while read -r net; do
        ipset add blocked_countries "$net" -exist
    done

    echo "[*] Done: $c"
done

echo "[*] Applying firewall rules..."

for p in $(echo "$PORTS" | tr ',' ' '); do
    iptables -C INPUT -p tcp --dport "$p" -m set --match-set blocked_countries src -j DROP 2>/dev/null \
    || iptables -I INPUT -p tcp --dport "$p" -m set --match-set blocked_countries src -j DROP
done

netfilter-persistent save >/dev/null 2>&1

echo "================================="
echo "Firewall updated successfully!"
echo "Blocked countries: $COUNTRIES"
echo "Protected ports: $PORTS"
echo "Persistence: ENABLED"
echo "================================="
