# 🌍 GeoIP Firewall Guard (iptables + ipset)

A universal firewall tool that blocks traffic from selected countries using GeoIP lists.

Works for:
- Telegram MTProxy / TeleMT
- SSH / VPS protection
- Web servers (Nginx/Apache)
- Any TCP service

---

## ⚙️ Features

- Country-based IP blocking (RU, PK, IQ, etc.)
- Multi-port protection
- Uses ipset (high performance)
- iptables integration
- Persistent across reboot
- Safe to re-run (no duplicates)

---

## 🚀 Quick Install (One Command)

```bash
curl -sSL https://raw.githubusercontent.com/TradeIP-telegram/geoip-firewall-guard/main/geoip-firewall-guard.sh | bash
