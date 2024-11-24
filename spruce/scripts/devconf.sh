#!/bin/sh

. /mnt/SDCARD/spruce/scripts/helperFunctions.sh
. /mnt/SDCARD/spruce/scripts/applySetting/settingHelpers.sh
. /mnt/SDCARD/spruce/bin/SSH/dropbearFunctions.sh

if flag_check "developer_mode" || flag_check "designer_mode"; then
   log_message "Developer mode enabled"
    # Turn off idle monitors
    update_setting "idlemon_in_game" "Off"
    update_setting "idlemon_in_menu" "Off"
    
    # Enable certain network services
    update_setting "samba" "on"
    update_setting "dropbear" "on"
    update_setting "sftpgo" "on"
    #update_setting "enableNetworkTimeSync" "on"
    
    # Dropbear first time setup and start
    first_time_setup &

    # App visibility
    /mnt/SDCARD/spruce/scripts/applySetting/showHideApp.sh show /mnt/SDCARD/App/FileManagement/config.json
    /mnt/SDCARD/spruce/scripts/applySetting/showHideApp.sh show /mnt/SDCARD/App/ShowOutputTest/config.json
fi