#!/bin/sh

. /mnt/SDCARD/spruce/scripts/helperFunctions.sh

WIFI_FILE="/config/wpa_supplicant.conf"

if [ -f /mnt/SDCARD/wifi.cfg ]; then
	. /mnt/SDCARD/wifi.cfg
else
	log_message "no wifi.cfg file found at SD root. Aborting supplicant.sh"
	exit 1
fi

if [ "$ID_1" = "" ] || [ "$PW_1" = "" ]; then
	log_message "Primary SSID or password missing. Aborting supplicant.sh"
	exit 1
fi

line_1="ctrl_interface=DIR=/var/run/wpa_supplicant"
line_2="update_config=1"
open="network={"
close="}"

rm -f "$WIFI_FILE"
touch "$WIFI_FILE"

begin_file() {
	echo "$line_1"
	echo "$line_2"
}

add_network() {
	echo ""
	echo "$open"
	echo "ssid=\"$ID\""
	echo "psk=\"$PW\""
	echo "priority=$PRIORITY"
	echo "$close"
}

begin_file >> "$WIFI_FILE"

ID="$ID_1"
PW="$PW_1"
PRIORITY=1
add_network >> "$WIFI_FILE"
log_message "Network $ID added to wpa_supplicant.conf"

if [ "$ID_2" = "" ] || [ "$PW_2" = "" ]; then
	exit 0
else
	ID="$ID_2"
	PW="$PW_2"
	PRIORITY=2
	add_network >> "$WIFI_FILE"
	log_message "Network $ID added to wpa_supplicant.conf"
fi

if [ "$ID_3" = "" ] || [ "$PW_3" = "" ]; then
	exit 0
else
	ID="$ID_3"
	PW="$PW_3"
	PRIORITY=3
	add_network >> "$WIFI_FILE"
	log_message "Network $ID added to wpa_supplicant.conf"
fi

if [ "$ID_4" = "" ] || [ "$PW_4" = "" ]; then
	exit 0
else
	ID="$ID_4"
	PW="$PW_4"
	PRIORITY=4
	add_network >> "$WIFI_FILE"
	log_message "Network $ID added to wpa_supplicant.conf"
fi

if [ "$ID_5" = "" ] || [ "$PW_5" = "" ]; then
	exit 0
else
	ID="$ID_5"
	PW="$PW_5"
	PRIORITY=5
	add_network >> "$WIFI_FILE"
	log_message "Network $ID added to wpa_supplicant.conf"
fi