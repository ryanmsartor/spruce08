#!/bin/sh

. "$HELPER_FUNCTIONS"

SETTINGS_FILE="/config/system.json"
SWAPFILE="/mnt/SDCARD/cachefile"
SDCARD_PATH="/mnt/SDCARD"

SPRUCE_LOGO="/mnt/SDCARD/spruce/imgs/bg_tree_sm.png"
FW_ICON="/mnt/SDCARD/Themes/SPRUCE/icons/App/firmwareupdate.png"
HAPPY_ICON="/mnt/SDCARD/spruce/imgs/smile.png"

log_message "Starting firstboot script"

# initialize the settings... users can restore their own backup later.
cp "${SDCARD_PATH}/.tmp_update/system.json" "$SETTINGS_FILE" && sync

if [ -f "/mnt/SDCARD/App/BootLogo/bootlogo.bmp"; then ]
    /mnt/SDCARD/App/BootLogo/launch.sh
    rm "/mnt/SDCARD/App/BootLogo/bootlogo.bmp"
fi

{
    if [ -f "${SWAPFILE}" ]; then
        SWAPSIZE=$(du -k "${SWAPFILE}" | cut -f1)
        MINSIZE=$((128 * 1024))
        if [ "$SWAPSIZE" -lt "$MINSIZE" ]; then
            swapoff "${SWAPFILE}"
            rm "${SWAPFILE}"
            log_message "Removed undersized swap file" -v
        fi
    fi
    if [ ! -f "${SWAPFILE}" ]; then
        dd if=/dev/zero of="${SWAPFILE}" bs=1M count=128
        mkswap "${SWAPFILE}"
        sync
        log_message "Created new swap file" -v
    fi
    
    /mnt/SDCARD/spruce/scripts/emufresh_md5_multi.sh
    /mnt/SDCARD/spruce/scripts/iconfresh.sh --silent
} &

VERSION=$(cat /usr/miyoo/version)
if [ "$VERSION" -lt 20240713100458 ]; then
    log_message "Detected firmware version $VERSION, suggesting update"
    display -i "$BG_IMAGE" --icon "$FW_ICON" -d 5 -p bottom -t "Visit the App section from the main menu to update your firmware to the latest version. It fixes the A30's Wi-Fi issues!"
fi

flag_remove "first_boot"
log_message "Removed first boot flag"
log_message "Finished firstboot script"
