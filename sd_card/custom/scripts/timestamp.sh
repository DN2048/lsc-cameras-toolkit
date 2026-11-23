#!/bin/sh

SD_DIR="/tmp/sd"
LOG_FILE="${SD_DIR}/logs/timestamp.log"
CUSTOM_DIR="${SD_DIR}/custom"
CFG_FILE="${CUSTOM_DIR}/configs/hack.conf"
BLANK_FILE="${CUSTOM_DIR}/other/ak_font_16_blank.bin"

load_cfg() {
    # Defaults
    TIMESTAMP=1

    if [ -f "${CFG_FILE}" ]; then
        # shellcheck disable=SC1090
        . "${CFG_FILE}"
    fi
}

load_cfg
exec >>"${LOG_FILE}" 2>&1

if [ "${TIMESTAMP}" = "0" ]; then
    mount --bind "${BLANK_FILE}" /usr/local/ak_font_16.bin || true
    log "Timestamp disabled."
fi
