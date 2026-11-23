#!/bin/sh

SD_DIR="/tmp/sd"
LOG_FILE="${SD_DIR}/logs/disable_led.log"
CUSTOM_DIR="${SD_DIR}/custom"
CFG_FILE="${CUSTOM_DIR}/configs/hack.conf"

load_cfg() {
    # Defaults
    DISABLE_LED=1

    if [ -f "${CFG_FILE}" ]; then
        # shellcheck disable=SC1090
        . "${CFG_FILE}"
    fi
}

load_cfg
exec >>"${LOG_FILE}" 2>&1

if [ "${DISABLE_LED}" = "1" ]; then
    mount --bind "${CUSTOM_DIR}/other/empty.sh" /usr/sbin/state_led.sh || true
    echo none > /sys/class/leds/state_led/trigger 2>/dev/null
    echo 0 > /sys/class/leds/state_led/brightness 2>/dev/null
    log "LED disabled."
fi
