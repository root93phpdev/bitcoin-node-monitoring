#!/bin/bash
set -euo pipefail

METRICS_DIR="/var/lib/prometheus/node-exporter"
METRICS_FILE="${METRICS_DIR}/bitcoin_service.prom"
TMP_FILE=$(mktemp "${METRICS_DIR}/bitcoin_service.prom.XXXXXX")

cleanup() {
    rm -f "$TMP_FILE"
}
trap cleanup EXIT

SERVICE_STATUS=0

if systemctl is-active --quiet bitcoind.service; then
    SERVICE_STATUS=1
fi

cat > "$TMP_FILE" <<EOF
# HELP bitcoin_systemd_service_up Whether Bitcoin Core systemd service is active
# TYPE bitcoin_systemd_service_up gauge
bitcoin_systemd_service_up ${SERVICE_STATUS}
EOF

chmod 640 "$TMP_FILE"
chown root:prometheus "$TMP_FILE"
mv "$TMP_FILE" "$METRICS_FILE"
