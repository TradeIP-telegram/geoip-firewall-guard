#!/bin/bash
# =========================================
# GeoIP Firewall Guard (iptables + ipset)
# Universal production-grade firewall
# =========================================

set -e

echo "==== GeoIP Firewall Guard ===="

# -------- CONFIG --------
read -p "Enter ports to protect (comma-separated, e.g. 2053,8443): " PORTS
read -p "Enter countries to block (comma-separated, e.g. ru,pk,iq): " COUNTRIES

IFS=',' read -r -a PORT_ARRAY <<< "$PORTS"
IFS=',' read -r -a COUNTRY_ARRAY <<< "$COUNTRIES"

# -------- INSTALL DEPENDENCIES --------
echo "[*] Installing dependencies..."
apt update
apt install -y ipset iptables-persistent wget curl

# -------- CLEAN EXISTING SET (NO DUPLICATES) --------
echo "[*] Resetting ipset..."
ipset destroy blocked_countries 2>/dev/null || true
ipset create blocked_countries hash:net

# -------- IPSET RULES --------
echo "[*] Adding iptables rules..."
for PORT in "${PORT_ARRAY[@]}"; do
    iptables -C INPUT -p tcp --dport "$PORT" -m set --match-set blocked_countries src -j DROP 2>/dev/null \
    || iptables -I INPUT -p tcp --dport "$PORT" -m set --match-set blocked_countries src -j DROP
done

# -------- DOWNLOAD + LOAD COUNTRIES --------
echo "[*] Loading GeoIP data..."
mkdir -p /etc/ipset

for CODE in "${COUNTRY_ARRAY[@]}"; do
    FILE="/etc/ipset/${CODE}.zone"

    echo "  -> $CODE"
    wget -q -O "$FILE" "https://www.ipdeny.com/ipblocks/data/countries/${CODE}.zone"

    # Add IPs safely (no duplicates because ipset is clean each run)
    while read -r IP; do
        ipset add blocked_countries "$IP" 2>/dev/null || true
    done < "$FILE"
done

# -------- SAVE PERSISTENT --------
echo "[*] Saving configuration..."
ipset save > /etc/ipset/blocked_countries.save
netfilter-persistent save

echo "[+] DONE"
echo "[+] Ports protected: $PORTS"
echo "[+] Countries blocked: $COUNTRIES"
echo "[+] Universal firewall active (not TeleMT-specific)"
