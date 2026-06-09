# GeoIP Firewall Guard

A lightweight firewall tool using `iptables + ipset` to block traffic from selected countries.

---

## Features

- Block multiple countries (RU, PK, IQ, etc.)
- Protect multiple TCP ports
- Safe re-run (no duplicate rules)
- Works with MTProxy, SSH, web servers, etc.
- Production-safe CLI argument mode (no broken curl prompts)

---

## Installation

```bash
curl -sSL https://raw.githubusercontent.com/TradeIP-telegram/geoip-firewall-guard/main/geoip-firewall-guard.sh | bash -s -- --ports 2053,8443 --countries ru,pk,iq

---

## Notes

- When running via `curl | bash`, the script runs in **non-interactive mode**
- In this mode, **no flush prompt is shown**
- Default behavior is applied automatically
- For full control (including prompts), run locally:

```bash
bash geoip-firewall-guard.sh
```

