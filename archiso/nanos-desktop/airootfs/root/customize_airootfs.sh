#!/usr/bin/env bash
# customize_airootfs.sh
#
# Runs inside the chroot during mkarchiso, after packages are installed but
# before the squashfs image is created. This is the right place for changes
# that need to survive symlink quirks (e.g. /etc/os-release is normally a
# symlink to /usr/lib/os-release on Arch — a plain airootfs file copy can
# behave inconsistently there, but a chroot command always wins).

set -e -u

echo "==> Branding: overwriting os-release symlink with nanOS identity"
rm -f /etc/os-release
cp /etc/nanos/nanos-os-release /etc/os-release

echo "==> Enabling zram-generator"
systemctl enable systemd-zram-setup@zram0.service || true

echo "==> customize_airootfs.sh done"
