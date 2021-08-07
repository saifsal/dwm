# dwm

## Overview

Personal build of [dwm](https://dwm.suckless.org/) for Saif Salih (`saifsal/dwm`). Upstream version is **6.8** (`config.mk`). The repository is the suckless C sources plus local configuration and two helper programs used from keybindings and `.xinitrc`.

The purpose is to compile and install `dwm`, `status`, and `brave-open` into `/usr/local` (default `PREFIX`). Programs named from config (Alacritty, Brave, dmenu, WirePlumber `wpctl`, `backlight`, Cozette) are expected on the machine; this repository does not install them.

Current status: the files on `main` are the working configuration. There is no package, changelog, roadmap, release tag beyond the upstream version string, installer beyond `make install`, test suite, or CI workflow. Licence is the MIT/X Consortium text in `LICENSE` (upstream suckless copyright holders).

## Repository layout

```
LICENSE
Makefile
README.md
AGENTS.md
brave-open
config.conf
config.def.h
config.h
config.mk
drw.c
drw.h
dwm.1
dwm.c
dwm.png
status
transient.c
util.c
util.h
```

- `dwm.c`, `drw.c` / `drw.h`, `util.c` / `util.h` are the window manager and drawing helpers.
- `config.def.h` is the editable configuration template. Appearance, tags, rules, layouts, and keybindings live here.
- `config.h` is what the build compiles against. If missing, `make` copies it from `config.def.h`. Both files are tracked and currently match.
- `config.mk` sets `VERSION`, `PREFIX` (`/usr/local`), compiler flags, and X11 / FreeType link lines.
- `Makefile` builds `dwm` and installs `dwm`, `status`, and `brave-open` plus the man page.
- `status` is a shell script: bar text via `xsetroot -name`, volume (`wpctl`), backlight (`backlight`), optional `BAT0`, and a `--daemon` loop. Keybindings in `config.def.h` call it for volume and backlight.
- `brave-open` finds a file under `$HOME` with `find` + `dmenu` and opens it in Brave.
- `config.conf` is a **neofetch** config. dwm does not read it.
- `dwm.1` is the man page. `transient.c` is an upstream helper source. `dwm.png` is the logo image.
- `LICENSE` is MIT/X Consortium (upstream).

## Setup

Clone and build:

```bash
git clone git@github.com:saifsal/dwm.git
cd dwm
make
sudo make install
```

Edit `config.mk` if `PREFIX`, include paths, or flags need to match the host. Default install paths are `${PREFIX}/bin` and `${MANPREFIX}/man1` with `PREFIX=/usr/local`.

After install, start an X session that runs `dwm`. The owner’s `~/.xinitrc` (in the separate `saifsal/dotfiles` repo) does `picom -b`, `status --daemon`, `feh --bg-scale -z ~/.config/wallpaper/`, then `exec dwm`.

Programs and fonts this build names, none of which are shipped here:

- Build: a C99 compiler (`cc`), Xlib, Xinerama, libXft, fontconfig / FreeType headers.
- Runtime from `config.def.h`: `alacritty`, `brave`, `dmenu_run`, font **Cozette**.
- From `status`: `wpctl`, `backlight`, `xsetroot`; battery path `/sys/class/power_supply/BAT0` when present.
- From `brave-open`: `/usr/bin/find`, `/usr/local/bin/dmenu`, `/usr/bin/brave`.

## Build, run and test

There is no automated test suite. From the repository root these succeed on a machine with the X11 build deps:

```bash
make clean
make
bash -n status
bash -n brave-open
```

`make` produces `./dwm`. `bash -n` only parses the scripts. Running dwm under X, `status --daemon`, and `make install` were not required for those checks.

Useful targets: `make` / `make all`, `make clean`, `make install`, `make uninstall`, `make dist` (tarball; expects `README` among other files — this tree uses `README.md`).

## Configuration notes

Local changes relative to a stock dwm 6.8 config live mainly in `config.def.h` / `config.h`:

- Font: `Cozette`. Terminal: `alacritty`. Browser: `brave`. File opener: `brave-open` (Mod1+o).
- Volume: Mod1+z / a / s → `status volume --toggle|--decrease|--increase`.
- Backlight: Mod1+u / y and Shift variants → `status backlight ...`.
- `MODKEY` is `Mod1Mask` (Alt).
- `refreshrate` is `120`.

After editing config, keep `config.def.h` and `config.h` in sync (or delete `config.h` and let `make` regenerate it), then `make clean install`.

## Code style and conventions

- C follows suckless style already in the tree: tabs for indentation in `.c` / `.h`, K&R-ish layout, short identifiers. Prefer minimal diffs against upstream patterns in `dwm.c` / `drw.c`.
- Configuration belongs in `config.def.h` (and matching `config.h`), not ad-hoc edits deep in `dwm.c`, unless a patch truly requires core changes.
- `status` and `brave-open` are shell. `status` starts with `#!/bin/sh` but uses `[[`, which needs a bash-compatible `/bin/sh` (true on this Arch host where `/bin/sh` → `bash`). Prefer absolute paths when adding new external commands, matching `brave-open`.
- Man page `dwm.1` uses the upstream troff style; substitute `VERSION` at install time via `sed`.
- Do not rewrite `LICENSE` copyright lines casually; they are upstream attributions.

## CI and tooling

Not applicable. There is no `.github/workflows` directory, formatter, or linter beyond what `make` and the compiler warn about.

## Working rules for agents

- Keep changes small and focused.
- Prefer editing `config.def.h` (and `config.h`) for keybind / appearance changes.
- Run `make` and `bash -n` on touched scripts before committing.
- Never commit secrets.
- Update this file and `README.md` when behaviour or layout changes in a user-visible way.
- Use conventional commit messages when the owner asks for a commit.

## Gotchas

- `config.h` is tracked. Deleting it makes `make` recreate it from `config.def.h`. Editing only one of the two leaves them divergent.
- `make dist` still lists a file named `README`; this repository documents with `README.md`.
- `config.mk` uses `X11INC = /usr/X11R6/include` and `X11LIB = /usr/X11R6/lib`. Those paths may be absent on Linux; the build can still succeed if the compiler finds headers via default system paths.
- `status` volume mute uses `@DEFAULT_AUDION_SINK@` (typo: extra `N`). Increase/decrease use `@DEFAULT_AUDIO_SINK@`. Mute may no-op until that string is fixed.
- `status --daemon` must be started outside dwm (for example from `.xinitrc`) or the bar status text will not refresh on its own.
- `brave-open` prunes many directories (dotdirs, `node_modules`, `target`, etc.) and only lists regular files under `$HOME`.
- `config.conf` does not affect dwm; changing it will not change the window manager.
- Install writes to `/usr/local` by default and usually needs elevated privileges.
- This tree is not the dotfiles repo. Session startup (`picom`, `feh`, wallpaper path) lives in `saifsal/dotfiles`, not here.
