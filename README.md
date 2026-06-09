# GeoIP Firewall Guard

A universal firewall tool using iptables + ipset to block traffic from selected countries.

---

## Features

- Block multiple countries (RU, PK, IQ, etc.)
- Protect multiple TCP ports
- Optional full firewall reset at start
- Safe re-run (no duplicate rules)
- Works with MTProxy, SSH, web servers, etc.
- Rules persist across reboot (via netfilter-persistent)

---

## One-line install

```bash
curl -sSL https://raw.githubusercontent.com/TradeIP-telegram/geoip-firewall-guard/main/geoip-firewall-guard.sh | bash
