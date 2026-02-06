#!/usr/bin/env bash
set -euo pipefail

HORIZON_URL="http://localhost:8000"
CORE_PORT=11626

echo "# HELP pi_node_horizon_up Horizon API up"
echo "# TYPE pi_node_horizon_up gauge"
curl -sf "${HORIZON_URL}/" >/dev/null && echo "pi_node_horizon_up 1" || echo "pi_node_horizon_up 0"

echo "# HELP pi_node_core_up Stellar Core port up"
echo "# TYPE pi_node_core_up gauge"
nc -z localhost ${CORE_PORT} && echo "pi_node_core_up 1" || echo "pi_node_core_up 0"

CPU=$(awk '{print $1}' /proc/loadavg)
MEM=$(free | awk '/Mem:/ {print $3/$2 * 100}')

echo "pi_node_cpu_load ${CPU}"
echo "pi_node_memory_used_percent ${MEM}"
