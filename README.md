# GeoIP Firewall Guard

A universal firewall guard script to block traffic from specific countries on selected TCP ports.

## Features

- Interactive port and country selection
- Uses `ipset` + `iptables` for high performance
- Avoids duplicate IPs in ipset
- Can be rerun safely
- Works with any TCP service, not just MTProxy

## Usage

1. Make the script executable:

\`\`\`bash
chmod +x geoip-firewall-guard.sh
\`\`\`

2. Run the script interactively:

\`\`\`bash
./geoip-firewall-guard.sh
\`\`\`

- Enter the ports to protect (comma-separated)
- Enter the countries to block (ISO 2-letter codes, comma-separated)

The firewall will be updated automatically.

## Notes

- Dependencies (`ipset`, `iptables-persistent`, `wget`, `curl`) are installed automatically.
- Designed to be rerun; it avoids duplicates in ipset and iptables.
- Can be used on any server, not just MTProxy.

