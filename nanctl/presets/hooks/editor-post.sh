#!/usr/bin/env bash
set -euo pipefail

# Official Arch repos don't ship VS Code (proprietary MS build); the AUR
# package requires an AUR helper we don't assume is installed. Simplest
# path that works on a bare system: download the official tarball directly
# and drop it in /opt, symlink the binary into PATH.

echo "Downloading VS Code (official tarball)..."
curl -L "https://code.visualstudio.com/sha/download?build=stable&os=linux-x64" \
  -o /tmp/vscode.tar.gz

echo "Installing to /opt/vscode..."
sudo mkdir -p /opt/vscode
sudo tar -xzf /tmp/vscode.tar.gz -C /opt/vscode --strip-components=1
sudo ln -sf /opt/vscode/bin/code /usr/local/bin/code
rm -f /tmp/vscode.tar.gz

echo "VS Code installed. Run: code"
