# dwm

Personal fork of [dwm](https://dwm.suckless.org/) 6.8, a small dynamic window manager for X. dwm tiles windows, gets out of the way, and keeps its configuration in C that you recompile. This tree is that window manager plus the configuration and status helper used on this desktop: the Cozette font, Alt bindings for Alacritty, dmenu, and Brave, and a `status` script for the bar, volume, and backlight.

![dwm logo](dwm.png)

`dwm.png` is the upstream logo. The repository does not include a screenshot of a running session.

## Features

- Three layouts, switched at runtime: tiled master and stack (`[]=`), floating (`><>`), and monocle (`[M]`). Tile is the default.
- Nine tags. A window can carry one tag or several. Each monitor has its own tag selection.
- A bar on each monitor showing tags, the layout symbol, the focused window title, and the root window name on the focused monitor.
- Xinerama multi-monitor support, enabled in `config.mk`.
- Compile-time configuration in `config.h`: colours, font, rules, commands, keys, and mouse buttons.
- A `status` helper that publishes volume, backlight, battery, and the clock into the bar, and that the volume and backlight keys call.
- Local behaviour in `dwm.c` on top of upstream 6.8: window titles drawn on the bar are reduced to printable ASCII, a fullscreen window moved to another monitor is resized to that monitor, 32-bit X properties are read as `long` only when the format is 32, the status-text click target matches the rectangle the bar draws, and `_NET_ACTIVE_WINDOW` is updated even for clients that never take input focus.

Gimp is forced floating. Firefox opens on tag 9.

## Prerequisites

To build:

- A C compiler invoked as `cc`
- X11, Xft, Xinerama, FreeType, and fontconfig headers and libraries

On Debian or Ubuntu:

```sh
sudo apt install build-essential libx11-dev libxft-dev libxinerama-dev libfreetype6-dev libfontconfig1-dev
```

To run the window manager as configured:

- An X server, and dwm as the only window manager on that display
- The Xft font `Cozette` (or change `fonts` in `config.h`)
- `alacritty`, `dmenu_run`, and `brave` for the launch keys
- `status` on `PATH` (installed by `make install`)
- `wpctl` for volume, a program named `backlight` for the backlight keys, and `xsetroot` so `status` can update the bar
- `/sys/class/power_supply/BAT0` if the battery field should show a charge

`config.mk` points `X11INC` and `X11LIB` at `/usr/X11R6`. Plain `make` still works when the compiler's default search path already contains X11, which is the case on Ubuntu with the packages above. If the build cannot find X11, set those two variables in `config.mk`.

## Install

```sh
make
sudo make install
```

`PREFIX` defaults to `/usr/local` and `MANPREFIX` to `$PREFIX/share/man`. Both can be overridden, and `DESTDIR` is prepended to the install path:

```sh
make PREFIX=/usr/local DESTDIR=/tmp/dwm-root install
```

That installs:

| Path | What |
| --- | --- |
| `$PREFIX/bin/dwm` | The window manager |
| `$PREFIX/bin/status` | Bar, volume, and backlight helper |
| `$MANPREFIX/man1/dwm.1` | Man page, with the version written in |

`make uninstall` removes those three files.

## Usage

dwm has to be the window manager for the X session. A typical `.xinitrc` for this fork is:

```sh
status --daemon &
exec dwm
```

`status --daemon` updates the root window name every second. dwm shows that string on the right of the bar. Until something sets the name, the bar reads `dwm-6.8`.

Quit with Alt-Shift-q.

`dwm` accepts one flag. `dwm -v` prints `dwm-6.8` to stderr and exits 1. Any other argument prints `usage: dwm [-v]` and exits 1.

### Keyboard

The modifier is Alt (`Mod1Mask`). Bindings below are what `config.h` compiles in. The man page still describes upstream dwm (terminal `st`, Alt-Return to zoom, Alt-b to toggle the bar) and does not match this file.

| Keys | Action |
| --- | --- |
| Alt-Return | Launch `alacritty` |
| Alt-p | Launch `dmenu_run` |
| Alt-b | Launch `brave` |
| Alt-Shift-b | Toggle the bar |
| Alt-j / Alt-k | Focus next / previous window |
| Alt-h / Alt-l | Shrink / grow the master area |
| Alt-i / Alt-d | More / fewer windows in the master area |
| Alt-Shift-Return | Move the focused window into the master area |
| Alt-t / Alt-f / Alt-m | Tile / float / monocle |
| Alt-Space | Toggle between the current and previous layout |
| Alt-Shift-Space | Toggle the focused window between tiled and floating |
| Alt-Shift-c | Close the focused window |
| Alt-Tab | Toggle back to the previously selected tags |
| Alt-1 … Alt-9 | View that tag |
| Alt-0 | View every tag |
| Alt-Shift-1 … Alt-Shift-9 | Move the focused window to that tag |
| Alt-Shift-0 | Tag the focused window with every tag |
| Alt-Ctrl-1 … Alt-Ctrl-9 | Add or remove that tag from the view |
| Alt-Ctrl-Shift-1 … Alt-Ctrl-Shift-9 | Add or remove that tag on the focused window |
| Alt-Comma / Alt-Period | Focus the previous / next monitor |
| Alt-Shift-Comma / Alt-Shift-Period | Send the focused window to the previous / next monitor |
| Alt-a / Alt-s | Volume down / up by 1% |
| Alt-z | Toggle mute |
| Alt-y / Alt-u | Backlight down / up |
| Alt-Shift-y / Alt-Shift-u | Backlight to minimum / maximum |
| Alt-Shift-q | Quit dwm |

Volume and backlight keys run `status`. Volume also needs `wpctl`. Backlight also needs the external `backlight` program.

### Mouse

| Click | Action |
| --- | --- |
| Tag, button 1 | View that tag |
| Tag, button 3 | Add or remove that tag from the view |
| Alt-click tag, button 1 | Move the focused window to that tag |
| Alt-click tag, button 3 | Add or remove that tag on the focused window |
| Layout symbol, button 1 | Toggle between the current and previous layout |
| Layout symbol, button 3 | Monocle |
| Window title, button 2 | Zoom the focused window into the master area |
| Status text, button 2 | Launch `alacritty` |
| Alt-drag a window, button 1 | Move it (tiled windows become floating) |
| Alt-click a window, button 2 | Toggle floating |
| Alt-drag a window, button 3 | Resize it (tiled windows become floating) |

### status

`status` prints or updates one line:

```text
<volume> | <backlight> | <battery> | <weekday> <day> W<week> <month> <year> | <hour>:<minute>:<second> <zone>
```

The clock uses `date +"%A %d W%V %B %Y | %_H:%M:%S %Z"`. Battery text is the `BAT0` status and capacity, and only when that power supply exists. Empty fields stay empty, so the separators are still printed.

```sh
status --show
status --daemon
status volume --show
status volume --increase
status volume --decrease
status volume --toggle
status backlight --show
status backlight --increase
status backlight --decrease
status backlight --maximum
status backlight --minimum
status backlight --set 40
```

`status --show` prints the combined line and leaves the root window name alone. `volume --show` and `backlight --show` print only that field. The other subcommands call `xsetroot -name` with the combined line, which is what dwm displays. `--daemon` repeats that once a second and does not exit.

Run the no-argument usage check with bash (`bash status`). See Development for why `/bin/sh` on Debian and Ubuntu does not.

## Configuration

Edit `config.h` and rebuild. dwm does not read a runtime config file. The settings this fork changes from upstream `config.def.h` are:

| Setting | Value |
| --- | --- |
| `fonts` | `Cozette` |
| `dmenucmd` | `dmenu_run` with no extra arguments |
| `termcmd` | `alacritty` |
| `browsercmd` | `brave` |
| `borderpx` | 1 |
| `snap` | 32 |
| `mfact` | 0.55 |
| `nmaster` | 1 |
| `resizehints` | 1 (honour size hints while tiling) |
| `lockfullscreen` | 1 (keep focus on a fullscreen window) |
| `refreshrate` | 120 (move and resize motion is limited to this rate) |
| `showbar`, `topbar` | bar on, at the top |
| Colours | `#222222`, `#444444`, `#bbbbbb`, `#eeeeee`, selection `#005577` |
| Rules | Gimp floating; Firefox on tag 9 |

`config.mk` holds the version, install prefixes, feature flags, and compiler flags. Comment out `XINERAMALIBS` and `XINERAMAFLAGS` to drop Xinerama.

`config.conf` is a neofetch config that happens to be in the tree. dwm does not load it.

After changing `config.h` or `config.mk`, run `make` and restart dwm.

## Development and testing

There is no test suite. The checks that exist are the build, the version flag, and the status script.

```sh
make
./dwm -v
bash status
bash status --show
make clean
```

`make` produces `./dwm` and, with the packages in Prerequisites, completes without warnings. `./dwm -v` prints `dwm-6.8` to stderr and exits 1. That exit status is what `die()` does; it does not mean the binary failed to link. `bash status` with no arguments prints usage and exits 1. `bash status --show` prints the bar line and exits 0. On Debian and Ubuntu, `/bin/sh` is dash, and the no-argument check in `status` uses bash `[[`. `./status` under that shell prints `[[: not found` and exits 0 without the usage text.

`make clean` removes `dwm`, object files, and `dwm-6.8.tar.gz`.

`make dist` does not succeed. The recipe copies `README` and `config.def.h`. This repository has `README.md` and `config.h` instead, so `cp` cannot stat either name and `make` stops with `Error 1`. The failed recipe leaves a `dwm-6.8/` directory that `make clean` does not delete.

`transient.c` is a small X client for watching floating and transient windows. It is not in the Makefile:

```sh
cc transient.c -o transient -lX11
```

It maps a fixed 400×400 window named `floating`, waits five seconds, then maps a transient named `transient`, and then blocks in the X event loop.

Do not commit `dwm`, `*.o`, `dwm-6.8/`, or `dwm-6.8.tar.gz`. The repository has no `.gitignore`.

## Project status

The tree is dwm 6.8 with the local configuration and the `dwm.c` changes listed above. History on `main` is two commits, `6.5` and `6.8`. The 6.5 tree had spiral and dwindle layouts in `fibonacci.c`; those are not present now.

There is no roadmap in the repository. There is no CI.

## Licence

[MIT/X Consortium License](LICENSE). The copyright notices and the permission text are in that file. GitHub classifies the same text as the MIT License. There is no additional licence.
