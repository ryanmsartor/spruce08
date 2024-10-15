#!/bin/sh

. /mnt/SDCARD/spruce/scripts/helperFunctions.sh
EMU_DIR="/mnt/SDCARD/Emu"
ROM_DIR="/mnt/SDCARD/Roms"
P8_DIR="$EMU_DIR/PICO8"
show_img="/mnt/SDCARD/App/EMUFRESH/refreshing.png"

##### DEFINE FUNCTIONS #####

delete_cache_files() {
    find $ROM_DIR -name "*cache6.db" -exec rm {} \;
}

is_hidden() {
    json_file="$1/config.json"
    [ -f "$json_file" ] && grep -q '"#label"' "$json_file" && return 0 || return 1
}

has_roms() {
    system_name="$(basename "$1")"
    search_dir="$ROM_DIR/$system_name"
    json_file="$1/config.json"
    extensions="$(jq -r '.extlist' "$json_file" | tr '|' ' ')"


    if [ ! -f "$json_file" ]; then
        return 1
    fi

    for ext in $extensions; do
        if find "$search_dir" -type f -name "*.$ext" | grep -q .; then
            return 0
        fi
    done

    return 1
}

hide_system() {
    if ! is_hidden "$1"; then
        sed -i 's|"label"\:|"\#label"\:|' "$1/config.json"
    fi
}

unhide_system() {
    if is_hidden "$1"; then
        sed -i 's|"\#label"\:|"label"\:|' "$1/config.json"
    fi
}

##### MAIN EXECUTION #####

if [ -f "$show_img" ]; then
    show "$show_img" &
fi

delete_cache_files

for dir in "$EMU_DIR"/*; do
    if [ -d "$dir" ]; then
        if has_roms "$dir"; then
            unhide_system "$dir"
        else
            hide_system "$dir"
        fi
    fi
done

if [ -f "$P8_DIR/bin/pico8.dat" ] && [ -f "$P8_DIR/bin/pico8_dyn" ]; then
    unhide_system "$P8_DIR"
else
    hide_system "$P8_DIR"
fi

killall -9 show