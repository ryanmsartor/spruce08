#!/bin/sh

. "$HELPER_FUNCTIONS"

SETTINGS_FILE="/config/system.json"
SWAPFILE="/mnt/SDCARD/cachefile"
SDCARD_PATH="/mnt/SDCARD"

BG_IMAGE="/mnt/SDCARD/spruce/imgs/displayTextPreColor.png"
SPRUCE_LOGO="/mnt/SDCARD/spruce/imgs/spruce_logo.png"
FW_ICON="/mnt/SDCARD/Themes/SPRUCE/icons/App/firmwareupdate.png"
HAPPY_ICON="/mnt/SDCARD/spruce/imgs/smile.png"

if flag_check "first_boot"; then
    log_message "First boot flag detected. Running first boot procedure"
    {
        cp "${SDCARD_PATH}/.tmp_update/system.json" "$SETTINGS_FILE" && sync

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

    display -d 3 -i "$BG_IMAGE" --icon "$SPRUCE_LOGO" -t "Installing spruce08 v0.1.0!
     " -p bottom

    VERSION=$(cat /usr/miyoo/version)
    if [ "$VERSION" -lt 20240713100458 ]; then
        log_message "Detected firmware version $VERSION, suggesting update" -v
        display -i "$BG_IMAGE" --icon "$FW_ICON" -d 5 -p bottom -t "Visit the App section from the main menu to update your firmware to the latest version. It fixes the A30's Wi-Fi issues!
         "
    fi
    
    log_message "Displaying enjoy image"
    display -d 3 -i "$BG_IMAGE" --icon "$HAPPY_ICON" -p bottom -t "Happy gaming..........!
     "

    flag_remove "first_boot"
    log_message "Removed first boot flag" -v
else
    log_message "First boot flag not found. Skipping first boot procedures."
fi
