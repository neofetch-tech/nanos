# Changelog

## v1.0 — nanctl

First stable release. Scope: `nanctl` as a standalone preset/plugin
manager for Arch Linux.

**What's in:**
- `nanctl` (Rust CLI) — `install`, `list`, `status`, `plugin add/list/run-hook`
- Lua plugin engine (`mlua`), sandboxed: `nanos.print`, `nanos.exec_readonly`
  (whitelisted commands only), `nanos.exec` (permission-gated, shown to the
  user before install). Verified against a plugin attempting an
  unauthorized command — correctly blocked.
- `nanos-sysinfo` (C) — reads RAM/CPU/load directly from `/proc`, zero
  deps, wired into `nanctl status`
- Presets: `devtools` (gcc/cargo/make/cmake), `browser` (Firefox),
  `editor` (VS Code), `cluster` (Docker + k3s, traefik/servicelb/
  metrics-server disabled by default)
- `nanctl install` runs `pacman -Sy` before installing, so it works on a
  freshly installed system with no synced package database

**Not in this release:**
- The nanOS live ISO (`archiso/`) — boots inconsistently, hit a kernel
  panic during testing. Kept in the repo as experimental/unfinished;
  `nanctl` itself has no dependency on it and installs fine on any
  existing Arch system.
- Terminal configurator website

## Unreleased

- nanOS branding: /etc/os-release rewritten to identify as nanOS (fixes
  login banner showing "Arch Linux"), applied via customize_airootfs.sh
  to reliably overwrite the os-release symlink
- neofetch added, configured with a custom nanOS ASCII logo
  (/etc/xdg/neofetch/config.conf, /etc/nanos/nanos-ascii.txt), runs
  automatically on every interactive login via /etc/profile.d
- PLUGINS.md: full guide for writing nanctl plugins
- docs/index.html: landing page, terminal-styled, ready for GitHub Pages
