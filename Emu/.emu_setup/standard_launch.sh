#!/bin/sh
# One Emu launch.sh to rule them all!
# Ry 2024-09-24

##### DEFINE BASE VARIABLES #####

. /mnt/SDCARD/spruce/scripts/helperFunctions.sh
log_message "-----Launching Emulator-----" -v
log_message "trying: $0 $@" -v
export EMU_NAME="$(echo "$1" | cut -d'/' -f5)"
export GAME="$(basename "$1")"
export EMU_DIR="/mnt/SDCARD/Emu/${EMU_NAME}"
export DEF_DIR="/mnt/SDCARD/Emu/.emu_setup/defaults"
export DEF_FILE="$DEF_DIR/${EMU_NAME}.opt"

. "$DEF_FILE"

##### SET CPU MODE #####

if [ "$MODE" = "overclock" ]; then
	set_overclock
elif [ "$MODE" != "performance" ]; then
	/mnt/SDCARD/spruce/scripts/enforceSmartCPU.sh &
fi

##### LAUNCH STUFF #####

case $EMU_NAME in
	"PICO8")
        # send signal USR2 to joystickinput to switch to KEYBOARD MODE
        # this allows joystick to be used as DPAD in MainUI
        killall -USR2 joystickinput

		export HOME="$EMU_DIR"
		export PATH="$HOME"/bin:$PATH
		export LD_LIBRARY_PATH="$HOME"/lib-cine:$LD_LIBRARY_PATH
		export SDL_VIDEODRIVER=mali
		export SDL_JOYSTICKDRIVER=a30
		cd "$HOME"
		sed -i 's|^transform_screen 0$|transform_screen 135|' "$HOME/.lexaloffle/pico-8/config.txt"
		if [ "${GAME##*.}" = "splore" ]; then
			check_and_connect_wifi
			pico8_dyn -splore -width 640 -height 480 -root_path "/mnt/SDCARD/Roms/PICO8/"
		else
			pico8_dyn -width 640 -height 480 -scancodes -run "$1"
		fi
		sync

        # send signal USR1 to joystickinput to switch to ANALOG MODE
        killall -USR1 joystickinput

		;;

	"PORTS")
		PORTS_DIR=/mnt/SDCARD/Roms/PORTS
		cd $PORTS_DIR
		/bin/sh "$1"
		;;
	*)
		if setting_get "expertRA"; then
			export RA_BIN="retroarch"
		else
			export RA_BIN="ra32.miyoo"
		fi
		RA_DIR="/mnt/SDCARD/RetroArch"
		cd "$RA_DIR"

		HOME="$RA_DIR/" "$RA_DIR/$RA_BIN" -v -L "$RA_DIR/.retroarch/cores/${CORE}_libretro.so" "$1"

		;;
		
esac

kill -9 $(pgrep enforceSmartCPU.sh)
log_message "-----Closing Emulator-----" -v
