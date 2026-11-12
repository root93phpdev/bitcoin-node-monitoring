
# Bitcoin Node Monitoring

A self-hosted monitoring solution for Bitcoin Core running on Linux.

The project collects Bitcoin node and system metrics using Bash scripts, exports them to Prometheus through Node Exporter, and enables visualization with Grafana.

## Overview

This project provides monitoring of:

- Bitcoin blockchain synchronization
- Block height and headers
- Peer connections
- Blockchain storage usage
- Bitcoin Core service status
- Linux system resources

## Architecture

```text
+----------------------+
|     Bitcoin Core     |
|      bitcoind        |
+----------+-----------+
           |
           v
+----------------------+
|    Bash Scripts      |
|  Bitcoin Metrics     |
|  Service Monitoring  |
+----------+-----------+
           |
           v
+----------------------+
|    Node Exporter     |
|   Textfile Collector |
+----------+-----------+
           |
           v
+----------------------+
|     Prometheus       |
+----------+-----------+
           |
           v
+----------------------+
|       Grafana        |
|     Dashboards       |
+----------------------+
```

## Technology Stack

| Technology | Purpose |
|---|---|
| Ubuntu Linux | Operating system |
| Bitcoin Core | Bitcoin full node |
| Bash | Monitoring automation |
| systemd | Service management |
| Node Exporter | Metrics exporter |
| Prometheus | Metrics collection |
| Grafana | Data visualization |
| jq | JSON processing |

## Project Structure

```text
bitcoin-node-monitoring/
├── prometheus/
│   └── prometheus.yml
├── scripts/
│   ├── bitcoin_metrics.sh
│   ├── bitcoin_service_check.sh
│   └── monitor.sh
├── systemd/
│   ├── bitcoind.service
│   ├── bitcoin-metrics.service
│   └── bitcoin-metrics.timer
├── .gitignore
└── README.md
```

## Features

### Bitcoin Core Monitoring

- Current block height
- Known block headers
- Blocks synchronization progress
- Blocks behind calculation
- Initial block download status
- Peer connections (inbound/outbound)
- Bitcoin Core uptime
- Blockchain storage usage
- Pruning status

### Linux System Monitoring

- CPU load
- RAM usage
- Swap usage
- Disk space
- Bitcoin data directory size

### Automation

- Bash-based metrics collection
- systemd service management
- systemd timer for periodic execution
- Prometheus-compatible metrics

## Prometheus Metrics

Custom Bitcoin metrics are written in Prometheus text exposition format.

| Metric | Description |
|---|---|
| bitcoin_blocks | Current validated block height |
| bitcoin_headers | Known block headers |
| bitcoin_blocks_behind | Difference between headers and blocks |
| bitcoin_sync_progress | Blockchain verification progress |
| bitcoin_initial_block_download | Initial block download status |
| bitcoin_connections | Total peer connections |
| bitcoin_connections_in | Inbound peer connections |
| bitcoin_connections_out | Outbound peer connections |
| bitcoin_uptime_seconds | Bitcoin Core uptime |
| bitcoin_blocks_size_bytes | Blocks directory size |
| bitcoin_chainstate_size_bytes | Chainstate directory size |
| bitcoin_pruned | Whether pruning is enabled |
| bitcoin_service_up | Bitcoin Core service status |
| bitcoin_systemd_service_up | systemd service status |

## Requirements

- Ubuntu Linux
- Bitcoin Core
- Prometheus
- Node Exporter with textfile collector
- Grafana
- Bash
- jq
- systemd

## Status

The monitoring infrastructure and initial metric collection scripts have been implemented.

Documentation, deployment instructions, dashboard configuration and additional monitoring improvements are in progress.
