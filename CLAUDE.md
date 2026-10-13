<!-- AGENTS.md is the canonical source for this file. -->

# dwm

## Overview

Personal fork of [dwm](https://dwm.suckless.org/) 6.8, the dynamic window manager for X. The GitHub description is "My fork of dwm". It manages windows in tiled, monocle, and floating layouts, groups them with nine tags, and draws a per-monitor bar. Configuration is compile-time C in `config.h`, which is the usual suckless model.

This tree tracks the 6.8 sources. Compared with the [dwm 6.8 tarball](https://dl.suckless.org/dwm/dwm-6.8.tar.gz), `drw.c`, `drw.h`, `util.c`, `util.h`, `transient.c`, `config.mk`, `dwm.1`, `dwm.png`, and `LICENSE` are unchanged. Local differences are:

- `config.h` is committed (upstream ships `config.def.h` and generates `config.h`). The font is Cozette. The terminal is `alacritty`, the launcher is `dmenu_run`, and the browser is `brave`. Alt bindings also drive volume and backlight through the `status` helper.
- `status` is a shell helper, installed next to `dwm`, that sets the root window name and adjusts volume and backlight.
- `Makefile` `install` and `uninstall` also install and remove `status`.
- `dwm.c` sanitizes window titles before drawing them, aligns the status-text click target with the status rectangle that is actually drawn, reads 32-bit X properties as `long` only when the property format is 32, resizes a fullscreen client to the destination monitor in `sendmon`, and updates `_NET_ACTIVE_WINDOW` even when a client is marked `neverfocus`.
- `config.conf` is a neofetch configuration. Nothing in the build or the window manager reads it.

The previous commit, `6.5`, included `fibonacci.c` (spiral and dwindle layouts). Those layouts are not in this tree.

There is no test suite and no CI. The program is the current desktop configuration, not a separately versioned release.

## Repository layout

| Path | Role |
| --- | --- |
| `dwm.c` | Window manager. Start at `main()`. Keys, buttons, colours, and rules come from `config.h`. |
| `drw.c`, `drw.h` | Xft drawing helpers used by the bar. |
| `util.c`, `util.h` | `die()` and `ecalloc()`. |
| `config.h` | Compile-time configuration. Included by `dwm.c`. |
| `config.mk` | `VERSION` (6.8), install prefixes, include and library paths, `CFLAGS`, `LDFLAGS`. |
| `Makefile` | `all`, `clean`, `dist`, `install`, `uninstall`. |
| `status` | Bar text, volume, and backlight helper. Installed to `$PREFIX/bin`. |
| `dwm.1` | Upstream man page. Its keyboard section does not match `config.h`. |
| `transient.c` | Standalone X11 program that maps a fixed-size window and a transient. Not built by `make`. |
| `config.conf` | neofetch configuration. Not used by dwm. |
| `dwm.png` | Upstream dwm logo, 192×80. Not a screenshot of this configuration. |
| `LICENSE` | MIT/X Consortium License. |

There is no `config.def.h` and no `.gitignore`. There is no CI workflow. `make dist` still expects a file named `README` and a file named `config.def.h`. The human documentation is `README.md`, which does not satisfy that recipe.

## Setup

Build dependencies are a C compiler (`cc`) and headers plus libraries for X11, Xft, Xinerama, FreeType, and fontconfig. On Debian or Ubuntu:

```sh
sudo apt install build-essential libx11-dev libxft-dev libxinerama-dev libfreetype6-dev libfontconfig1-dev
```

`make` completed without warnings on Ubuntu once `libx11-dev`, `libxft-dev`, `libxinerama-dev`, `libfreetype6-dev`, and `libfontconfig1-dev` were installed. `cc` was clang 18. The compiler flags come from `config.mk`.

`config.mk` sets `X11INC` to `/usr/X11R6/include` and `X11LIB` to `/usr/X11R6/lib`. Those directories are not required when the compiler and linker already search the system X11 paths. On the Ubuntu machine used to check the build, `/usr/X11R6` does not exist and plain `make` still linked. If X11 is somewhere else, edit `X11INC` and `X11LIB` in `config.mk`. FreeType headers default to `/usr/include/freetype2`. The commented OpenBSD lines in `config.mk` are the upstream alternatives; leave them commented on Linux.

To build without Xinerama, comment out `XINERAMALIBS` and `XINERAMAFLAGS` in `config.mk`.

Runtime requirements beyond an X server:

- An Xft font named `Cozette`, unless `fonts` in `config.h` is changed. If no listed font loads, dwm exits with `no fonts could be loaded.`
- `alacritty`, `dmenu_run`, and `brave` for the launch bindings.
- `status` on `PATH` for the volume and backlight bindings. `make install` copies it to `$PREFIX/bin`.
- `wpctl` (WirePlumber) for volume, an external program named `backlight` for the backlight bindings (`backlight g`, `backlight i`, `backlight d`, `backlight s <n>`), and `xsetroot` so `status` can set the root window name.
- `/sys/class/power_supply/BAT0` if the battery field should be filled. The name is hardcoded in `status`.

## Build, run and test

There is no test suite and no `make test` target. Commands below were run from a clean tree except where noted.

Build:

```sh
make
```

`make` compiles `drw.c`, `dwm.c`, and `util.c` and links `./dwm`. It completed with no warnings. Object files depend on `config.h` and `config.mk`, so editing either and running `make` rebuilds.

Version check:

```sh
./dwm -v
```

This prints `dwm-6.8` to stderr and exits 1. `die()` always exits 1. It does not open a display.

Run dwm only as the sole window manager on an X display:

```sh
status --daemon &
exec dwm
```

`status --daemon` loops, calling `xsetroot -name` once a second. dwm reads that root-window name into the bar. If the name is unset, the bar shows `dwm-6.8`. Starting `./dwm` while another window manager is already running exits 1 with `dwm: another window manager is already running`. With no display it exits 1 with `dwm: cannot open display`. A full session was not started during the docs check, because a window manager already owned `DISPLAY`.

`status` with no arguments, under bash:

```sh
bash status
```

prints the usage line and exits 1. `bash status --show` prints one status line and exits 0. Invoking `./status` through `/bin/sh` when that shell is dash does not print usage; see Gotchas.

Install and uninstall honour `PREFIX` (default `/usr/local`), `MANPREFIX` (default `$PREFIX/share/man`), and `DESTDIR`:

```sh
make install
make uninstall
sudo make PREFIX=/usr/local install
```

`make DESTDIR=/tmp/dwm-root install` installed `bin/dwm`, `bin/status`, and `share/man/man1/dwm.1`, with `VERSION` in the man page replaced by `6.8`. `make DESTDIR=/tmp/dwm-root uninstall` removed those three files.

Clean:

```sh
make clean
```

This deletes `./dwm`, the `.o` files, and `dwm-6.8.tar.gz`. It does not delete a leftover `dwm-6.8/` directory.

`make dist` fails. The recipe copies `README` and `config.def.h`. This tree has `README.md` and `config.h` instead, so `cp` reports both missing paths and `make` exits with `Error 1`. A partial `dwm-6.8/` directory is left behind. Do not commit that directory.

`transient.c` is not part of `make`. It compiles with the command in its first comment:

```sh
cc transient.c -o transient -lX11
```

That compile succeeded. The program was not run: it maps windows and then loops on `XNextEvent`.

## Code style and conventions

C sources follow suckless dwm style:

- Indent with tabs. The file header points at `LICENSE`.
- K&R functions: the return type is on its own line, the name starts at column 0, and the opening brace is on the next line.
- Short `if` bodies usually omit braces and stay on the following line. Match the function you are editing. `sanitize_name` is an exception and uses braces; leave surrounding code alone.
- Types, static functions, and macros already in the file are the pattern for new code. `Client *c`, `UPPER_CASE` macros, and `static` for file-local functions.
- `config.h` is included from `dwm.c`. Behaviour that upstream expects you to change (keys, mouse buttons, colours, fonts, rules, commands, `mfact`, `nmaster`) belongs there, not in new conditionals in `dwm.c`.
- Compiler flags in `config.mk` are `-std=c99 -pedantic -Wall -Wno-deprecated-declarations -Os`, plus `-D_DEFAULT_SOURCE -D_BSD_SOURCE -D_XOPEN_SOURCE=700L -DVERSION=\"6.8\" -DXINERAMA`.

`status` is a shell script with a `#!/bin/sh` shebang and a bash `[[` test. Match the existing script when editing it. `config.conf` is neofetch syntax; it is not dwm configuration.

There is no formatter, linter, or `.editorconfig`. Do not reindent unrelated lines.

## CI and tooling

Not applicable for CI. The repository has no GitHub Actions workflow and no other CI configuration.

Tooling that does exist:

- `Makefile` and `config.mk`, as described above.
- `cc` for `dwm` and, separately, for `transient.c`.
- `sed` in the `install` rule, to substitute `VERSION` into `dwm.1`.

No formatter, linter, or test runner is configured.

## Working rules for agents

- Keep changes small and focused.
- Run the tests before committing. There is no automated suite; run `make`, then `./dwm -v`, and expect `dwm-6.8` on stderr and exit status 1. If you change `status`, also run `bash status` and `bash status --show`.
- Never commit secrets. Do not commit build output either: `dwm`, `*.o`, `dwm-6.8/`, or `dwm-6.8.tar.gz`. There is no `.gitignore`.
- Update the docs when behaviour changes. That includes `README.md` and these instruction files when commands, keybindings, layout, or setup change.
- Use conventional commit messages.
- Keep `AGENTS.md`, `CLAUDE.md`, and `.github/copilot-instructions.md` in sync. `AGENTS.md` is canonical. The other two must be the same text, plus at most a one-line header noting that this file is canonical. Do not replace them with symlinks.
- Do not start `./dwm` when another window manager already owns the display.
- After editing `config.h` or `config.mk`, rebuild. Keybindings call whatever binaries are on `PATH` at runtime.

## Gotchas

- `dwm.1` documents upstream bindings: Mod1-Shift-Return starts `st`, Mod1-Return zooms, and Mod1-b toggles the bar. `config.h` does not. Alt-Return starts `alacritty`, Alt-Shift-Return zooms, Alt-b starts `brave`, and Alt-Shift-b toggles the bar. The man page installed by `make install` only substitutes the version string.
- `spawn()` still writes the monitor index into `dmenumon` when the command is `dmenucmd`, but `dmenucmd` is `{ "dmenu_run", NULL }` and never passes `-m` or `dmenumon`.
- `status` uses `[[`. Under dash as `/bin/sh`, `./status` with no arguments prints `[[: not found` and exits 0 without the usage text. Under bash it prints usage and exits 1.
- `volume_toggle` calls `wpctl set-mute @DEFAULT_AUDION_SINK@`. The other volume functions use `@DEFAULT_AUDIO_SINK@`. The toggle name is misspelled.
- `battery()` prints nothing and returns 0 or 1. `status()` checks it with `if $(battery)`. That keeps the exit status only while `battery` prints nothing. An `echo` inside `battery` would make the `if` execute that output as a command.
- The same `$(function)` pattern is used for the volume and backlight actions. Those functions currently print nothing.
- The battery device is `BAT0`. The bar line is `volume | backlight | battery | datetime`. With `wpctl`, `backlight`, and `BAT0` all absent, `--show` still prints the separators and the date.
- `status` is not started by dwm. Nothing updates the bar until some client, usually `status --daemon`, sets the root window name.
- Deleting `config.h` and running `make` tries to copy `config.def.h`, which is not in the repository.
- `make dist` looks for `README` and `config.def.h`, not `README.md` and `config.h`. It fails and leaves `dwm-6.8/`. `make clean` does not remove that directory.
- `./dwm -v` exits 1 even on success, because it goes through `die()`.
- dwm refuses to start if another window manager is already running. It is not a nested window manager.
- The 6.5 fibonacci layouts are gone. Do not expect `spiral`, `dwindle`, or `fibonacci.c`.
- `config.conf` is not read by the Makefile or by dwm.
