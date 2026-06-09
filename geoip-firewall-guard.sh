#!/bin/bash
echo "================================="
echo " GeoIP Firewall Guard"
echo "================================="

export DEBIAN_FRONTEND=noninteractive

# Install dependencies
apt update -y
apt install -y ipset iptables-persistent wget curl netcat-openbsd

# Ask ports and countries using /dev/tty explicitly
if [ -e /dev/tty ]; then
    read -rp "Enter ports to protect (example: 2053,8443): " PORTS </dev/tty
    read -rp "Enter countries to block (example: ru,pk,iq): " COUNTRIES </dev/tty
else
    echo "[!] No terminal detected, using defaults."
    PORTS="2053,8443"
    COUNTRIES="ru,pk,iq"
fi

# Clean input
PORTS=$(echo "$PORTS" | tr -d '[:space:]')
COUNTRIES=$(echo "$COUNTRIES" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')

# Prepare ipset
ipset create blocked_countries hash:net -exist
ipset flush blocked_countries

# Download GeoIP blocks and add
for c in $(echo "$COUNTRIES" | tr ',' ' '); do
    echo "[*] Loading $c..."
    curl -sSL "https://www.ipdeny.com/ipblocks/data/countries/${c}.zone" | while read -r net; do
        ipset add blocked_countries "$net" -exist
    done
done

# Apply iptables rules
for p in $(echo "$PORTS" | tr ',' ' '); do
    iptables -C INPUT -p tcp --dport "$p" -m set --match-set blocked_countries src -j DROP 2>/dev/null \
    || iptables -I INPUT -p tcp --dport "$p" -m set --match-set blocked_countries src -j DROP
done

netfilter-persistent save >/dev/null 2>&1

echo "================================="
echo "Firewall updated successfully!"
echo "Blocked countries: $COUNTRIES"
echo "Protected ports: $PORTS"
echo "================================="
