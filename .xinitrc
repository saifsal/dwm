#!/bin/sh
picom -b &
feh --bg-scale ~/.config/dwm/wallpaper.png &
dwmstatus.service &
exec dwm
