# dwm

Personal build of [dwm](https://dwm.suckless.org/) 6.8 (`saifsal/dwm`): the suckless dynamic window manager for X, with local `config.h` settings and two helpers installed alongside the binary.

## Requirements

To build: a C99 compiler, Xlib, Xinerama, libXft, and fontconfig / FreeType development files.

At runtime this config expects **Cozette**, **Alacritty**, **Brave**, **dmenu**, **WirePlumber** (`wpctl`), and a `backlight` command on `PATH` (see keybindings in `config.def.h`). The status bar is driven by the included `status` script via `xsetroot`.

## Installation

Edit `config.mk` if the install prefix or library paths need adjusting (default `PREFIX` is `/usr/local`).

```bash
make clean install
```

That installs `dwm`, `status`, and `brave-open` to `${PREFIX}/bin`, and the man page to `${MANPREFIX}/man1`.

## Running

From an X session (for example via `startx` and `~/.xinitrc`):

```sh
status --daemon &
exec dwm
```

`status --daemon` refreshes the bar every second (volume, backlight, battery when `BAT0` exists, date/time). Volume and backlight keys call `status` directly so the bar updates immediately.

## Configuration

Configuration is compile-time: edit `config.def.h`, keep `config.h` in sync (or remove `config.h` and let `make` copy from `config.def.h`), then rebuild:

```bash
make clean install
```

Notable local bindings (modifier is Alt / Mod1): terminal Return, dmenu `p`, Brave `b`, open file with `brave-open` `o`, volume `z`/`a`/`s`, backlight `u`/`y`.

## Helpers

| Program       | Role |
|---------------|------|
| `status`      | Bar text; `volume` / `backlight` subcommands; `--daemon` |
| `brave-open`  | `find` + dmenu picker under `$HOME`, open in Brave |

`config.conf` in this tree is a neofetch config and is unused by dwm.

## Licence

MIT/X Consortium — see `LICENSE`.
