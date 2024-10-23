#!/bin/sh

echo mmc0 >/sys/devices/platform/sunxi-led/leds/led1/trigger
echo L,L2,R,R2,X,A,B,Y > /sys/module/gpio_keys_polled/parameters/button_config
SETTINGS_FILE="/config/system.json"
SWAPFILE="/mnt/SDCARD/cachefile"
SDCARD_PATH="/mnt/SDCARD"
SCRIPTS_DIR="${SDCARD_PATH}/spruce/scripts"
BIN_DIR="${SDCARD_PATH}/spruce/bin"

export SYSTEM_PATH="${SDCARD_PATH}/miyoo"
export PATH="$SYSTEM_PATH/app:${PATH}"
export LD_LIBRARY_PATH="$SYSTEM_PATH/lib:${LD_LIBRARY_PATH}"
export HOME="${SDCARD_PATH}"
export HELPER_FUNCTIONS="/mnt/SDCARD/spruce/scripts/helperFunctions.sh"

mkdir /var/lib /var/lib/alsa ### Create the directories that by default are not included in the system.
mount -o bind "/mnt/SDCARD/miyoo/var/lib" /var/lib ### Mount the folder containing the alsa configuration, just as the system should include it.
mount -o bind /mnt/SDCARD/miyoo/app /usr/miyoo/app
mount -o bind /mnt/SDCARD/miyoo/lib /usr/miyoo/lib
mount -o bind /mnt/SDCARD/miyoo/res /usr/miyoo/res
mount -o bind "/mnt/SDCARD/miyoo/etc/profile" /etc/profile

# Load helper functions and helpers
. ${SCRIPTS_DIR}/helperFunctions.sh
. ${SCRIPTS_DIR}/runtimeHelper.sh

rotate_logs &

SPLASH="/mnt/SDCARD/spruce/imgs/spruce08.bmp"
display -i "$SPLASH"

# Resetting log file location
log_file="/mnt/SDCARD/Saves/spruce/spruce.log"

# Flag cleanup
flag_remove "themeChanged"
flag_remove "log_verbose"
flag_remove "low_battery"

log_message "---------Starting up---------"

# Generate wpa_supplicant.conf from wifi.cfg if available
${SCRIPTS_DIR}/multipass.sh

# Check if WiFi is enabled
wifi=$(grep '"wifi"' /config/system.json | awk -F ':' '{print $2}' | tr -d ' ,')
if [ "$wifi" -eq 0 ]; then
    touch /tmp/wifioff && killall -9 wpa_supplicant && killall -9 udhcpc && rfkill
    log_message "WiFi turned off"
else
    touch /tmp/wifion
    log_message "WiFi turned on"
fi
killall -9 main ### SUPER important in preventing .tmp_update suicide
kill_images ##### this can probably be removed! - RS

# Bring up network and services
nice -n 15 ${SCRIPTS_DIR}/wpa_watchdog.sh > /dev/null &
${SCRIPTS_DIR}/wifi_watchdog.sh > /dev/null &

# Check for first_boot flag and run ThemeUnpacker accordingly
if flag_check "first_boot"; then
    ${SCRIPTS_DIR}/ThemeUnpacker.sh --silent &
    log_message "ThemeUnpacker started silently in background due to firstBoot flag"
else
    ${SCRIPTS_DIR}/ThemeUnpacker.sh
fi

alsactl nrestore ###We tell the sound driver to load the configuration.
log_message "ALSA configuration loaded"

# ensure keymon is running first and only listen to event0 for power button & event3 for keyboard events
# keymon /dev/input/event0 &
keymon /dev/input/event3 &
${SCRIPTS_DIR}/powerbutton_watchdog.sh &

# rename ttyS0 to ttyS2 so that PPSSPP cannot read the joystick raw data
mv /dev/ttyS0 /dev/ttyS2
# create virtual joypad from keyboard input, it should create /dev/input/event4 system file
cd ${BIN_DIR}
./joypad /dev/input/event3 &
sleep 0.3 ### wait long enough to create the virtual joypad
# read joystick raw data from serial input and apply calibration,
# then send analog input to /dev/input/event4 when in ANALOG_MODE (this is default)
# and send keyboard input to /dev/input/event3 when in KEYBOARD_MODE.
# Please send kill signal USR1 to switch to ANALOG_MODE
# and send kill signal USR2 to switch to KEYBOARD_MODE
./joystickinput /dev/ttyS2 /config/joypad.config -axis /dev/input/event4 -key /dev/input/event3 &

# run game switcher watchdog before auto load game is loaded
${SCRIPTS_DIR}/gameswitcher_watchdog.sh &

# unhide -FirmwareUpdate- App only if necessary
VERSION="$(cat /usr/miyoo/version)"
if [ "$VERSION" -lt 20240713100458 ]; then
    sed -i 's|"#label":|"label":|' "/mnt/SDCARD/App/-FirmwareUpdate-/config.json"
    log_message "Detected firmware version $VERSION; enabling -FirmwareUpdate- app"
fi

# Load idle monitors before game resume or MainUI
${SCRIPTS_DIR}/applySetting/idlemon_mm.sh

"${SCRIPTS_DIR}/autoIconRefresh.sh" &

lcd_init 1

# check whether to run first boot procedure
if flag_check "first_boot"; then
    "${SCRIPTS_DIR}/firstboot.sh"
else
    log_message "First boot flag not found. Skipping first boot procedures."
fi

swapon -p 40 "${SWAPFILE}"
log_message "Swap file activated"

# Run scripts for initial setup
${SCRIPTS_DIR}/low_power_warning.sh
${SCRIPTS_DIR}/checkfaves.sh &
${SCRIPTS_DIR}/autoReloadCalibration.sh &
log_message "Initial setup scripts executed"
kill_images

# Initialize CPU settings
set_smart

# create splore launcher if it doesn't already exist
SPLORE_CART="/mnt/SDCARD/Roms/PICO8/-=☆ Launch Splore ☆=-.splore"
if [ ! -f "$SPLORE_CART" ]; then
	touch "$SPLORE_CART" && log_message "created $SPLORE_CART"
fi

# copy dat and dyn into place if they are at the root of your SD card
if [ -f "/mnt/SDCARD/pico8.dat" ] && [ ! -f "/mnt/SDCARD/Emu/PICO8/bin/pico8.dat" ]; then
    cp "/mnt/SDCARD/pico8.dat" "/mnt/SDCARD/Emu/PICO8/bin/pico8.dat"
fi
if [ -f "/mnt/SDCARD/pico8_dyn" ] && [ ! -f "/mnt/SDCARD/Emu/PICO8/bin/pico8_dyn" ]; then
    cp "/mnt/SDCARD/pico8_dyn" "/mnt/SDCARD/Emu/PICO8/bin/pico8_dyn"
fi

# tell principal.sh to run splore
echo "/mnt/SDCARD/Emu/PICO8/launch.sh \"$SPLORE_CART\"" > "/tmp/cmd_to_run.sh"

# start main loop
log_message "Starting main loop"
${SCRIPTS_DIR}/principal.sh