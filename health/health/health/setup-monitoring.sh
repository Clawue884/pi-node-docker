#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(pwd)"
LOG_DIR="/var/log"
HEALTH_DIR="${BASE_DIR}/health"
METRICS_DIR="${BASE_DIR}/metrics"
MONITORING_DIR="${BASE_DIR}/monitoring"

log() {
  echo -e "\033[1;32m[SETUP]\033[0m $*"
}

err() {
  echo -e "\033[1;31m[ERROR]\033[0m $*" >&2
  exit 1
}

check_cmd() {
  command -v "$1" >/dev/null 2>&1 || err "Command not found: $1"
}

log "Starting Pi Node Monitoring Setup..."

# 1. Check required commands
for cmd in docker docker-compose curl nc; do
  check_cmd "$cmd"
done

# 2. Create directories
log "Creating directories..."
mkdir -p "$HEALTH_DIR" "$METRICS_DIR" "$MONITORING_DIR"

# 3. Set permissions
log "Setting executable permissions..."
chmod +x "$HEALTH_DIR"/*.sh "$METRICS_DIR"/*.sh 2>/dev/null || true

# 4. Setup alert config
if [[ ! -f "$HEALTH_DIR/alert_config.env" ]]; then
  if [[ -f "$HEALTH_DIR/alert_config.env.example" ]]; then
    cp "$HEALTH_DIR/alert_config.env.example" "$HEALTH_DIR/alert_config.env"
    log "Created alert_config.env from example. Please edit it!"
  else
    log "alert_config.env.example not found. Skipping."
  fi
else
  log "alert_config.env already exists."
fi

# 5. Validate key files
REQUIRED_FILES=(
  "$HEALTH_DIR/healthcheck.sh"
  "$HEALTH_DIR/auto_recover.sh"
  "$HEALTH_DIR/alert_manager.sh"
  "$METRICS_DIR/node_metrics.sh"
  "$METRICS_DIR/metrics_server.sh"
  "$MONITORING_DIR/prometheus.yml"
  "$MONITORING_DIR/grafana-dashboard.json"
  "docker-compose.production.yml"
)

log "Validating required files..."
for file in "${REQUIRED_FILES[@]}"; do
  [[ -f "$file" ]] && log "OK: $file" || err "Missing file: $file"
done

# 6. Final instructions
log "Setup completed successfully!"

cat <<EOF

Next steps:
1) Edit Telegram / alert config:
   nano health/alert_config.env

2) Start monitoring stack:
   docker compose -f docker-compose.production.yml up -d

3) Access services:
   Grafana    → http://localhost:3000  (admin / piadmin)
   Prometheus → http://localhost:9090
   Metrics    → http://localhost:9105

Your Pi Node is now ready for production-grade monitoring 🚀
EOF
