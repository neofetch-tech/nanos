#!/usr/bin/env bash
set -euo pipefail

echo "Enabling docker..."
sudo systemctl enable --now docker

echo "Installing k3s (minimal profile, no traefik/servicelb/metrics-server)..."
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server \
  --disable traefik \
  --disable servicelb \
  --disable metrics-server" sh -

echo "k3s installed. Check with: sudo k3s kubectl get nodes"
