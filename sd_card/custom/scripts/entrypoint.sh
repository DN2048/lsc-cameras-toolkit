#!/bin/sh
SD_DIR="/tmp/sd"
CUSTOM_DIR="${SD_DIR}/custom"
SCRIPTS_DIR="${CUSTOM_DIR}/scripts"

/bin/sh "${SCRIPTS_DIR}/disable_led.sh" >/dev/null 2>&1 &
/bin/sh "${SCRIPTS_DIR}/dump_fs.sh" >/dev/null 2>&1 &
/bin/sh "${SCRIPTS_DIR}/ftp.sh" >/dev/null 2>&1 &
/bin/sh "${SCRIPTS_DIR}/nightmode.sh" >/dev/null 2>&1 &
/bin/sh "${SCRIPTS_DIR}/offline.sh" >/dev/null 2>&1 &
/bin/sh "${SCRIPTS_DIR}/timestamp.sh" >/dev/null 2>&1 &
/bin/sh "${SCRIPTS_DIR}/wifi_apply.sh" >/dev/null 2>&1 &

log "entrypoint done (all service scripts launched in background)"
