# nanOS

A terminal-first, Arch-based Linux distribution: small RAM footprint, sway as
a minimal compositor, `nanctl` as the customization layer (presets + Lua
plugins).

## Repository structure

```
nanos/
├── archiso/
│   ├── nanos-desktop/     # ISO profile for Desktop (firefox/devtools optional)
│   └── nanos-server/      # ISO profile for Server (headless, minimal)
├── nanctl/                # CLI tool written in Rust (main product)
├── nanos-sysinfo/         # small C utility: reads RAM/CPU/load from /proc
└── plugins-example/       # example Lua plugin for nanctl
```

## Roadmap (realistic, step by step)

1. **[Done] Repo skeleton + `nanctl install` for a single preset**
2. **[Done] Lua plugin engine (`mlua`)**
   - sandboxed execution, permissions from plugin.toml, tested against a
     malicious-input plugin
3. **[Done] First archiso ISO build (Server profile)**
   - boots in QEMU, `switch-root` confirmed working
4. **[Done] `nanos-sysinfo` in C**
   - reads /proc/meminfo, /proc/cpuinfo, /proc/loadavg directly, zero deps,
     wired into `nanctl status` as a subprocess
5. **[Next] Welcome script polish (bash/zsh selection)**
   - already present, needs testing on the real ISO
6. **[Next] Desktop profile ISO (sway)**
7. **[Next] Terminal configurator website**
   - separate project, generates a TOML/dotfile the user downloads

## How to start development right now

```bash
# 1. nanctl — develop and test without building an ISO at all
cd nanctl
cargo run -- install devtools

# 2. nanos-sysinfo — build the C utility and put it in PATH so
#    `nanctl status` can find it
cd ../nanos-sysinfo
make
sudo make install    # installs to /usr/local/bin/nanos-sysinfo
../nanctl/target/debug/nanctl status

# 3. Once nanctl works — test the archiso build
#    (requires Arch Linux or Arch in Docker/VM/WSL; archiso is unavailable
#    on other distros)
cd ../archiso/nanos-server
sudo mkarchiso -v -o out/ .
```

## Why this stack

- **archiso** — the official Arch tool for building custom ISOs, no need to
  reinvent the wheel
- **nanctl in Rust** — the plugin system runs third-party code (Lua), memory
  safety matters here
- **nanos-sysinfo in C** — reads only from /proc, has no reason to touch
  anything else, so it gets no dependencies and no sandbox — just a small,
  fast, static binary
- **presets as TOML** — declarative, anyone can write their own preset
  without knowing Rust

## Getting nanos-sysinfo into the ISO

`airootfs/usr/local/bin/` in each archiso profile is where a prebuilt
`nanos-sysinfo` binary should be copied before running `mkarchiso` — files
placed there are copied byte-for-byte into the final image, so no compiler
needs to run at boot time:

```bash
cd nanos-sysinfo
make
cp nanos-sysinfo ../archiso/nanos-server/airootfs/usr/local/bin/
cp nanos-sysinfo ../archiso/nanos-desktop/airootfs/usr/local/bin/
```
