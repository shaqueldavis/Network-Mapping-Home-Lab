#!/usr/bin/env bash
# usage: ./compare_ips.sh baseline.txt newfile.log

baseline="$1"
scan="$2"

if [[ -z "$baseline" || -z "$scan" ]]; then
  echo "Usage: $0 baseline.txt newfile.log" >&2
  exit 2
fi

# Extract IPs from baseline (assumes first column is IP)
awk '{print $1}' "$baseline" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | sort -u > /tmp/baseline_ips.$$

# Extract IPs (and optional hostnames if present) from the scan file
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}(\s*\([^)]+\))?' "$scan" | awk '
{
  ip=$1
  match($0, /\(([^)]+)\)/, host)
  hostfield = (host[1] != "" ? host[1] : "-")
  print ip "\t" hostfield
}' | sort -u > /tmp/scan_hosts.$$

# Create a plain IP list from scan (for comm)
cut -f1 /tmp/scan_hosts.$$ | sort -u > /tmp/scan_ips.$$

echo
echo "IPs present in scan but NOT in baseline (UNAPPROVED / new devices):"
comm -23 /tmp/scan_ips.$$ /tmp/baseline_ips.$$ || true

echo
echo "IPs in baseline but NOT present in scan (approved but currently offline):"
comm -13 /tmp/scan_ips.$$ /tmp/baseline_ips.$$ || true

echo
echo "Scan report (IP -> hostname if available):"
cat /tmp/scan_hosts.$$
echo

# cleanup
rm -f /tmp/baseline_ips.$$ /tmp/scan_hosts.$$ /tmp/scan_ips.$$
