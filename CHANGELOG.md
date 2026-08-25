# Changelog

## v1.0 — First release

**What's in:**
- `nanctl` (Rust CLI) — `install`, `list`, `status`, `plugin add/list/run-hook`
- Lua plugin engine (`mlua`), sandboxed: `nanos.print`, `nanos.exec_readonly`
  (whitelisted commands), `nanos.exec` (permission-gated). Verified against
  a plugin attempting an unauthorized command — correctly blocked.
- `nanos-sysinfo` (C) — reads RAM/CPU/load directly from `/proc`, zero deps,
  wired into `nanctl status`
- nanOS Server ISO — boots (BIOS + UEFI via syslinux/systemd-boot), live
  root login, welcome script wired to `/etc/profile.d` (bash/zsh choice,
  offers Oh My Zsh on zsh)
- Presets: `devtools` (gcc/cargo/make/cmake), `browser` (Firefox),
  `cluster` (Docker + k3s, traefik/servicelb/metrics-server disabled),
  `editor` (VS Code via official tarball)
- `nanctl`, `nanos-sysinfo`, and default presets are baked directly into
  the ISO (`bake-binaries.sh`) — no manual setup needed after boot
- zram enabled by default (zstd, 50% of RAM)

**Known limitations (tracked for v1.1):**
- Desktop profile (sway + GUI presets) exists as an archiso profile but has
  not been build-tested yet — packages.x86_64 defined, boot config not
  verified
- Presets requiring network (`browser`, `cluster`, `editor`) are untested
  against a real network connection — verified only via `--dry-run` and one
  failed attempt in a network-less QEMU sandbox
- No terminal configurator website yet (separate project)

**Fixed during development (for the record, since these ate real time):**
- `switch-root` failure — missing `mkinitcpio.conf.d` archiso hook
- Passwordless root login — missing releng `/etc/shadow`
- `firstboot` wizard blocking login — missing default locale/timezone
- `nanctl install` now runs `pacman -Sy` before installing (was `-S`,
  which fails on a fresh system with no synced package database)
