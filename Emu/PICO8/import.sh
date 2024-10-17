#!/bin/sh

. /mnt/SDCARD/spruce/scripts/helperFunctions.sh

BBS_PATH="/mnt/SDCARD/Emu/PICO8/.lexaloffle/pico-8/bbs/carts"
ROM_PATH="/mnt/SDCARD/Roms/PICO8"
ROM_PATH_2="/mnt/SDCARD/Roms/FAKE08"

{
for cart in "$BBS_PATH"/*.p8.png ; do
	cartname="$(basename "$cart")"
	if [ -s "${cart}" ]; then
		cp -f "$cart" "$ROM_PATH/$cartname"
		log_message "$cartname imported to $ROM_PATH"
		cp -f "$cart" "$ROM_PATH_2/$cartname"
		log_message "$cartname imported to $ROM_PATH_2"
	fi
done
} &

display -t "Importing carts from Splore :)" -d 2

rm -f "$ROM_PATH/PICO8_cache6.db"
log_message "Done importing. Pico-8 romlist refreshed."