#!/usr/bin/env bash
# setup-boot-files.sh
#
# Populates an archiso profile directory with the bootloader config files
# it needs (profiledef.sh, pacman.conf, syslinux/grub/efiboot) by copying
# them from the official releng reference profile, then patches them for
# nanOS. Safe to re-run — it always overwrites with a clean, known-good
# result rather than accumulating manual edits.
#
# Usage:
#   ./setup-boot-files.sh nanos-server
#   ./setup-boot-files.sh nanos-desktop

set -euo pipefail

PROFILE="${1:-}"
if [ -z "$PROFILE" ]; then
    echo "Usage: $0 <nanos-server|nanos-desktop>"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE_DIR="$SCRIPT_DIR/$PROFILE"
RELENG="/usr/share/archiso/configs/releng"

if [ ! -d "$PROFILE_DIR" ]; then
    echo "error: profile directory not found: $PROFILE_DIR"
    exit 1
fi

if [ ! -d "$RELENG" ]; then
    echo "error: releng reference profile not found at $RELENG"
    echo "       install it with: sudo pacman -S archiso"
    exit 1
fi

echo "==> Copying bootloader configs from releng into $PROFILE..."
cp "$RELENG/pacman.conf" "$PROFILE_DIR/"
cp -r "$RELENG/efiboot" "$PROFILE_DIR/"
cp -r "$RELENG/syslinux" "$PROFILE_DIR/"
cp -r "$RELENG/grub" "$PROFILE_DIR/"

echo "==> Writing profiledef.sh for $PROFILE..."
cat > "$PROFILE_DIR/profiledef.sh" << EOF
#!/usr/bin/env bash
# shellcheck disable=SC2034
iso_name="$PROFILE"
iso_label="NANOS_\$(date --date="@\${SOURCE_DATE_EPOCH:-\$(date +%s)}" +%Y%m)"
iso_publisher="nanOS <https://github.com/yourname/nanos>"
iso_application="nanOS \$([ "$PROFILE" = "nanos-desktop" ] && echo Desktop || echo Server) Live/Install"
iso_version="\$(date --date="@\${SOURCE_DATE_EPOCH:-\$(date +%s)}" +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso')
bootmodes=('bios.syslinux'
           'uefi.systemd-boot')
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
bootstrap_tarball_compression=('zstd' '-c' '-T0' '--auto-threads=logical' '--long' '-19')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/etc/nanos/welcome.sh"]="0:0:755"
  ["/etc/profile.d/nanos-welcome.sh"]="0:0:755"
  ["/etc/profile.d/nanos-neofetch.sh"]="0:0:755"
  ["/usr/local/bin/nanctl"]="0:0:755"
  ["/usr/local/bin/nanos-sysinfo"]="0:0:755"
  ["/root/customize_airootfs.sh"]="0:0:755"
)
EOF

echo "==> Copying mkinitcpio live-boot config from releng..."
mkdir -p "$PROFILE_DIR/airootfs/etc"
if [ -d "$RELENG/airootfs/etc/mkinitcpio.conf.d" ]; then
    cp -r "$RELENG/airootfs/etc/mkinitcpio.conf.d" "$PROFILE_DIR/airootfs/etc/"
fi
if [ -f "$RELENG/airootfs/etc/mkinitcpio.conf" ]; then
    cp "$RELENG/airootfs/etc/mkinitcpio.conf" "$PROFILE_DIR/airootfs/etc/"
fi

echo "==> Copying passwordless root shadow file from releng..."
if [ -f "$RELENG/airootfs/etc/shadow" ]; then
    cp "$RELENG/airootfs/etc/shadow" "$PROFILE_DIR/airootfs/etc/shadow"
fi

echo "==> Ensuring bootloader packages are in packages.x86_64..."
PKG_FILE="$PROFILE_DIR/packages.x86_64"
for pkg in syslinux memtest86+ edk2-shell memtest86+-efi mkinitcpio-archiso; do
    if ! grep -qx "$pkg" "$PKG_FILE"; then
        echo "$pkg" >> "$PKG_FILE"
        echo "    added: $pkg"
    fi
done

echo "==> Setting default locale/timezone (skips the first-boot setup wizard)..."
mkdir -p "$PROFILE_DIR/airootfs/etc"
echo "LANG=en_US.UTF-8" > "$PROFILE_DIR/airootfs/etc/locale.conf"
ln -sf /usr/share/zoneinfo/UTC "$PROFILE_DIR/airootfs/etc/localtime"

echo "==> Done. You can now run:"
echo "    cd $PROFILE_DIR && sudo mkarchiso -v -o out/ ."
