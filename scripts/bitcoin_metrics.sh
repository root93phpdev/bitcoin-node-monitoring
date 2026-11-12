#!/bin/bash
set -euo pipefail

DATA_DIR="/var/lib/bitcoin/.bitcoin"
METRICS_DIR="/var/lib/prometheus/node-exporter"
METRICS_FILE="${METRICS_DIR}/bitcoin.prom"

TMP_FILE=$(mktemp "${METRICS_DIR}/bitcoin.prom.XXXXXX")

cleanup() {
    rm -f "$TMP_FILE"
}
trap cleanup EXIT

# Получаем данные Bitcoin Core
INFO=$(sudo -u bitcoin /usr/local/bin/bitcoin-cli \
    -conf="${DATA_DIR}/bitcoin.conf" \
    -datadir="${DATA_DIR}" \
    getblockchaininfo)

NETWORK=$(sudo -u bitcoin /usr/local/bin/bitcoin-cli \
    -conf="${DATA_DIR}/bitcoin.conf" \
    -datadir="${DATA_DIR}" \
    getnetworkinfo)

UPTIME=$(sudo -u bitcoin /usr/local/bin/bitcoin-cli \
    -conf="${DATA_DIR}/bitcoin.conf" \
    -datadir="${DATA_DIR}" \
    uptime)

# Извлекаем показатели
BLOCKS=$(echo "$INFO" | jq -r '.blocks')
HEADERS=$(echo "$INFO" | jq -r '.headers')
PROGRESS=$(echo "$INFO" | jq -r '.verificationprogress')
PRUNED=$(echo "$INFO" | jq -r '.pruned')
IBD=$(echo "$INFO" | jq -r '.initialblockdownload')

CONNECTIONS=$(echo "$NETWORK" | jq -r '.connections')
CONNECTIONS_IN=$(echo "$NETWORK" | jq -r '.connections_in // 0')
CONNECTIONS_OUT=$(echo "$NETWORK" | jq -r '.connections_out // 0')

BLOCKS_BEHIND=$((HEADERS - BLOCKS))
if (( BLOCKS_BEHIND < 0 )); then
    BLOCKS_BEHIND=0
fi

BLOCKS_SIZE=$(du -sb "${DATA_DIR}/blocks" | awk '{print $1}')
CHAINSTATE_SIZE=$(du -sb "${DATA_DIR}/chainstate" | awk '{print $1}')

SERVICE_STATUS=0
if systemctl is-active --quiet bitcoind; then
    SERVICE_STATUS=1
fi

PRUNED_VALUE=0
if [ "$PRUNED" = "true" ]; then
    PRUNED_VALUE=1
fi

IBD_VALUE=0
if [ "$IBD" = "true" ]; then
    IBD_VALUE=1
fi

# Формируем Prometheus metrics
cat > "$TMP_FILE" <<EOF
# HELP bitcoin_blocks Current validated block height
# TYPE bitcoin_blocks gauge
bitcoin_blocks ${BLOCKS}
# HELP bitcoin_headers Known block headers
# TYPE bitcoin_headers gauge
bitcoin_headers ${HEADERS}
# HELP bitcoin_blocks_behind Difference between headers and validated blocks
# TYPE bitcoin_blocks_behind gauge
bitcoin_blocks_behind ${BLOCKS_BEHIND}
# HELP bitcoin_sync_progress Blockchain verification progress
# TYPE bitcoin_sync_progress gauge
bitcoin_sync_progress ${PROGRESS}
# HELP bitcoin_initial_block_download Whether initial block download is active
# TYPE bitcoin_initial_block_download gauge
bitcoin_initial_block_download ${IBD_VALUE}
# HELP bitcoin_connections Number of peer connections
# TYPE bitcoin_connections gauge
bitcoin_connections ${CONNECTIONS}
# HELP bitcoin_connections_in Number of inbound peer connections
# TYPE bitcoin_connections_in gauge
bitcoin_connections_in ${CONNECTIONS_IN}
# HELP bitcoin_connections_out Number of outbound peer connections
# TYPE bitcoin_connections_out gauge
bitcoin_connections_out ${CONNECTIONS_OUT}
# HELP bitcoin_uptime_seconds Bitcoin Core process uptime in seconds
# TYPE bitcoin_uptime_seconds gauge
bitcoin_uptime_seconds ${UPTIME}
# HELP bitcoin_blocks_size_bytes Size of blocks directory
# TYPE bitcoin_blocks_size_bytes gauge
bitcoin_blocks_size_bytes ${BLOCKS_SIZE}
# HELP bitcoin_chainstate_size_bytes Size of chainstate directory
# TYPE bitcoin_chainstate_size_bytes gauge
bitcoin_chainstate_size_bytes ${CHAINSTATE_SIZE}
# HELP bitcoin_pruned Whether pruning is enabled
# TYPE bitcoin_pruned gauge
bitcoin_pruned ${PRUNED_VALUE}
# HELP bitcoin_service_up Whether Bitcoin Core service is active
# TYPE bitcoin_service_up gauge
bitcoin_service_up ${SERVICE_STATUS}
EOF

chmod 640 "$TMP_FILE"
chown root:prometheus "$TMP_FILE"
mv "$TMP_FILE" "$METRICS_FILE"
