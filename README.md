# GeoIP Firewall Guard

A universal firewall guard script to block traffic from specific countries on selected TCP ports.

## Features
- Interactive port and country selection
- Uses ipset + iptables for high performance
- Avoids duplicate IPs in ipset
- Can be rerun safely
- Works with any TCP service, not just MTProxy

## Installation & Usage
Run this single command:

\`\`\`bash
curl -sSL https://raw.githubusercontent.com/TradeIP-telegram/geoip-firewall-guard/main/geoip-firewall-guard.sh | bash
\`\`\`

## Notes
- Dependencies installed automatically
- Can be rerun safely
- Universal firewall, not only MTProxy
