#!/bin/sh

. /mnt/SDCARD/spruce/scripts/helperFunctions.sh
BG="/mnt/SDCARD/spruce/imgs/bg_tree.png"
EMU_NAME="$(echo "$1" | cut -d'/' -f5)"
CONFIG="/mnt/SDCARD/Emu/${EMU_NAME}/config.json"
SYS_OPT="/mnt/SDCARD/Emu/.emu_setup/options/${EMU_NAME}.opt"
. "$SYS_OPT"

display -i "$BG" -t "Core changed to $CORE"

sed -i 's|"Emu Core: genesis+gx-(✓PICODRIVE)-gearsystem"|"Emu Core: genesis+gx-picodrive-(✓GEARSYSTEM)"|g' "$CONFIG"
sed -i 's|"/mnt/SDCARD/Emu/.emu_setup/core/gearsystem.sh"|"/mnt/SDCARD/Emu/.emu_setup/core/genesis_plus_gx.sh"|g' "$CONFIG"
sed -i 's|CORE=.*|CORE=\"gearsystem\"|g' "$SYS_OPT"

sleep 3
display_kill
