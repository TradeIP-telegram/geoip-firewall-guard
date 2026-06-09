#!/bin/bash
echo "================================="
echo " GeoIP Firewall Guard"
echo "================================="

# Dependencies
apt update
apt install -y ipset iptables-persistent wget curl

# Interactive input from terminal
read -rp "Enter ports to protect (example: 2053,8443): " PORTS < /dev/tty
read -rp "Enter countries to block (example: ru,pk,iq): " COUNTRIES < /dev/tty

# Clean whitespace
PORTS=$(echo "$PORTS" | tr -d '[:space:]')
COUNTRIES=$(echo "$COUNTRIES" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')

# Prepare ipset
ipset create blocked_countries hash:net -exist
ipset flush blocked_countries

# Download country IPs and add to ipset
for c in $(echo "$COUNTRIES" | tr ',' ' '); do
    wget -qO- "https://www.ipdeny.com/ipblocks/data/countries/${c}.zone" | while read net; do
        ipset add blocked_countries "$net" -exist
    done
done

# Add iptables rules
for p in $(echo "$PORTS" | tr ',' ' '); do
    iptables -I INPUT -p tcp --dport "$p" -m set --match-set blocked_countries src -j DROP
done

echo "Firewall updated successfully!"
echo "Blocked countries: $COUNTRIES"
echo "Protected ports: $PORTS"
