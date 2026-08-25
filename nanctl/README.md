# nanctl

A preset + plugin manager for Arch Linux, written in Rust.

`nanctl` installs curated bundles of `pacman` packages ("presets") from
simple TOML files, and lets you extend your setup with sandboxed Lua
plugins — without writing raw `pacman` commands or trusting arbitrary
shell scripts from the internet.

## Why

Setting up a new Arch install usually means either running a long list of
`pacman -S` commands from memory, or copy-pasting someone else's install
script and hoping it doesn't do anything you didn't expect. `nanctl` gives
you a middle ground: declarative presets you can read before you run them,
and a plugin system where permissions are shown to you *before* install,
not buried in the source.

## Install

```bash
git clone https://github.com/neofetch-tech/nanos.git
cd nanos/nanctl
cargo build --release
sudo cp target/release/nanctl /usr/local/bin/
```

Requires `gcc` (nanctl vendors and compiles its own Lua interpreter on
build, no system Lua dependency needed).

### Or run it in Docker (no Rust toolchain needed locally)

```bash
docker build -t nanctl .
docker run --rm nanctl list
docker run --rm nanctl status
```

Note: `nanctl install <preset>` calls `pacman`, which only exists on Arch —
the Docker image is Debian-based, so that specific command won't work
inside the container. Everything else (`list`, `status`, `plugin`) works
fine, and it's a quick way to confirm the build is healthy without
installing anything locally.

## Usage

### Presets

A preset is a TOML file describing a group of packages and an optional
post-install hook:

```toml
# presets/devtools.toml
[preset]
name = "devtools"
description = "GCC, cargo, build essentials"
profile = ["desktop", "server"]

[packages]
pacman = ["gcc", "cargo", "make", "cmake", "pkg-config"]
```

```bash
nanctl list                       # see available presets
nanctl install devtools           # runs pacman -Sy + the package list
nanctl install devtools --dry-run # show what would run, don't execute
```

By default `nanctl` looks for presets in `/etc/nanos/presets`, falling
back to `./presets` for local development. Override with
`NANOS_PRESETS_DIR`.

Included presets: `devtools`, `browser` (Firefox), `editor` (VS Code),
`cluster` (Docker + k3s, with `traefik`/`servicelb`/`metrics-server`
disabled by default for a smaller footprint).

### Plugins (Lua, sandboxed)

Plugins are Lua scripts that hook into `nanctl` events. Each plugin ships
a manifest declaring exactly what it's allowed to do:

```toml
# plugin.toml
[plugin]
name = "git-status-prompt"
version = "0.1.0"

[permissions]
exec = false       # can this plugin run arbitrary shell commands?
network = false
hooks = ["shell_prompt"]
```

```lua
-- init.lua
nanos_hooks["shell_prompt"] = function()
    local branch = nanos.exec_readonly("git branch --show-current")
    nanos.print("current branch: " .. branch)
end
```

`nanos.exec_readonly` only allows a small whitelist of read-only commands
(git, ls, cat, pwd, whoami, date, uname) regardless of what the plugin
requests. `nanos.exec` (arbitrary commands) is only wired up if the
plugin's manifest declares `permissions.exec = true` — and `nanctl`
shows you that request before installing, so you can say no.

```bash
nanctl plugin add ./path/to/plugin   # shows requested permissions, asks to confirm
nanctl plugin list
nanctl plugin run-hook shell_prompt  # manually fire a hook (mostly for testing)
```

### System info

```bash
nanctl status
```

Shows `nanctl`'s own state plus live RAM/CPU/load info, read via a small
companion C utility (`nanos-sysinfo/`) that parses `/proc` directly — no
shelling out to `free`/`lscpu`.

## Project layout

```
nanctl/          nanctl itself (Rust)
nanos-sysinfo/   small C utility, RAM/CPU/load from /proc, used by `nanctl status`
```

## License

MIT
