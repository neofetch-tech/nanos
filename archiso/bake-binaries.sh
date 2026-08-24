#!/usr/bin/env bash
# bake-binaries.sh
#
# Builds nanctl (release) and nanos-sysinfo, then copies the resulting
# binaries plus the default presets into each archiso profile's airootfs.
# Run this before mkarchiso whenever nanctl/nanos-sysinfo/presets change —
# files under airootfs/ are copied byte-for-byte into the final ISO, so
# nothing here runs at boot time; it all has to be baked in beforehand.
#
# Usage:
#   ./bake-binaries.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "==> Building nanctl (release)..."
(cd "$ROOT_DIR/nanctl" && cargo build --release)

echo "==> Building nanos-sysinfo..."
(cd "$ROOT_DIR/nanos-sysinfo" && make)

for PROFILE in nanos-server nanos-desktop; do
    PROFILE_DIR="$SCRIPT_DIR/$PROFILE"
    if [ ! -d "$PROFILE_DIR" ]; then
        continue
    fi

    echo "==> Baking binaries into $PROFILE..."
    mkdir -p "$PROFILE_DIR/airootfs/usr/local/bin"
    cp "$ROOT_DIR/nanctl/target/release/nanctl" "$PROFILE_DIR/airootfs/usr/local/bin/nanctl"
    cp "$ROOT_DIR/nanos-sysinfo/nanos-sysinfo" "$PROFILE_DIR/airootfs/usr/local/bin/nanos-sysinfo"

    echo "==> Baking default presets into $PROFILE..."
    mkdir -p "$PROFILE_DIR/airootfs/etc/nanos/presets"
    cp -r "$ROOT_DIR/nanctl/presets/"* "$PROFILE_DIR/airootfs/etc/nanos/presets/"
done

echo "==> Done. nanctl and nanos-sysinfo will now be present on first boot."
echo "    Rebuild the ISO with: cd archiso/<profile> && sudo mkarchiso -v -o out/ ."
