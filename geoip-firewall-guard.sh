#!/bin/bash
echo "================================="
echo " GeoIP Firewall Guard"
echo "================================="

# Dependencies
apt update
apt install -y ipset iptables-persistent wget curl

# Ask for flush
read -rp "Do you want to flush previous iptables/ipset rules? (y/N): " FLUSH
FLUSH=${FLUSH,,}

if [[ "$FLUSH" == "y" ]]; then
    echo "[*] Flushing iptables rules..."
    iptables -F
    iptables -X
    iptables -t nat -F
    iptables -t nat -X
    iptables -t mangle -F
    iptables -t mangle -X
    ipset destroy blocked_countries 2>/dev/null || true
fi

# Force terminal input (important for curl | bash)
exec < /dev/tty

read -rp "Enter ports to protect (example: 2053,8443): " PORTS
read -rp "Enter countries to block (example: ru,pk,iq): " COUNTRIES

# Clean input
PORTS=$(echo "$PORTS" | tr -d '[:space:]')
COUNTRIES=$(echo "$COUNTRIES" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')

# Create ipset
ipset create blocked_countries hash:net -exist
ipset flush blocked_countries

# Load country IPs
for c in $(echo "$COUNTRIES" | tr ',' ' '); do
    echo "[*] Loading $c..."
    wget -qO- "https://www.ipdeny.com/ipblocks/data/countries/${c}.zone" | while read net; do
        ipset add blocked_countries "$net" -exist
    done
done

# Apply iptables rules
for p in $(echo "$PORTS" | tr ',' ' '); do
    iptables -I INPUT -p tcp --dport "$p" -m set --match-set blocked_countries src -j DROP
done

echo "================================="
echo "Firewall updated successfully!"
echo "Blocked countries: $COUNTRIES"
echo "Protected ports: $PORTS"
echo "================================="
