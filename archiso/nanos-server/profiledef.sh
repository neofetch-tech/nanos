#!/usr/bin/env bash
# shellcheck disable=SC2034
iso_name="nanos-server"
iso_label="NANOS_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="nanOS <https://github.com/yourname/nanos>"
iso_application="nanOS $([ "nanos-server" = "nanos-desktop" ] && echo Desktop || echo Server) Live/Install"
iso_version="$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y.%m.%d)"
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
  ["/usr/local/bin/nanctl"]="0:0:755"
  ["/usr/local/bin/nanos-sysinfo"]="0:0:755"
)
