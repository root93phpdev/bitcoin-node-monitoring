
#!/bin/bash

BITCOIN_CLI="/usr/local/bin/bitcoin-cli"
CONFIG="/var/lib/bitcoin/.bitcoin/bitcoin.conf"
DATA_DIR="/var/lib/bitcoin/.bitcoin"

echo "=========================================="
echo "          BITCOIN NODE MONITOR"
echo "=========================================="

echo "Date: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# 1. Bitcoin service
if systemctl is-active --quiet bitcoind; then
    echo "[OK] Bitcoin service: RUNNING"
else
    echo "[ERROR] Bitcoin service: STOPPED"
    exit 1
fi

# 2. Blockchain information
INFO=$(sudo -u bitcoin "$BITCOIN_CLI" \
    -conf="$CONFIG" getblockchaininfo 2>/dev/null)

if [ -z "$INFO" ]; then
    echo "[ERROR] RPC connection failed"
    exit 1
fi

BLOCKS=$(echo "$INFO" | jq -r '.blocks')
HEADERS=$(echo "$INFO" | jq -r '.headers')
PROGRESS=$(echo "$INFO" | jq -r '.verificationprogress')
PRUNED=$(echo "$INFO" | jq -r '.pruned')
SIZE=$(echo "$INFO" | jq -r '.size_on_disk')

CONNECTIONS=$(sudo -u bitcoin "$BITCOIN_CLI" \
    -conf="$CONFIG" getconnectioncount 2>/dev/null)

PERCENT=$(awk -v p="$PROGRESS" 'BEGIN {printf "%.4f", p*100}')
SIZE_HUMAN=$(numfmt --to=iec-i --suffix=B "$SIZE")

# 3. RAM
RAM=$(free -h | awk '/Mem:/ {print $3 " / " $2}')
RAM_AVAILABLE=$(free -h | awk '/Mem:/ {print $7}')
SWAP=$(free -h | awk '/Swap:/ {print $3 " / " $2}')

# 4. CPU load
CPU_LOAD=$(awk '{print $1, $2, $3}' /proc/loadavg)

# 5. Disk
# Проверяем файловую систему, на которой расположен Bitcoin Core
DISK=$(df -h / | awk 'NR==2 {print $4}')
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}')

# 6. Bitcoin data directory
# Получаем размер от имени владельца каталога
DATA_SIZE=$(sudo -u bitcoin du -sh "$DATA_DIR" 2>/dev/null | awk '{print $1}')

echo ""
echo "------------ BITCOIN ------------"
echo "Blocks:        $BLOCKS"
echo "Headers:       $HEADERS"
echo "Sync:          $PERCENT %"
echo "Connections:   $CONNECTIONS"
echo "Pruned:        $PRUNED"
echo "Blockchain:    $SIZE_HUMAN"
echo "Data directory: $DATA_SIZE"

echo ""
echo "------------- SYSTEM ------------"
echo "RAM used:      $RAM"
echo "RAM available: $RAM_AVAILABLE"
echo "Swap used:     $SWAP"
echo "CPU load:      $CPU_LOAD"
echo "Disk free:     $DISK"
echo "Disk usage:    $DISK_USAGE"

echo ""
echo "=========================================="
