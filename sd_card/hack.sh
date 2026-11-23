#!/bin/sh

SD_DIR="/tmp/sd"
CUSTOM_DIR="${SD_DIR}/custom"
LOGS_DIR="${SD_DIR}/logs"
SCRIPTS_DIR="${CUSTOM_DIR}/scripts"
CONFIG_DIR="${CUSTOM_DIR}/configs"
CFG_FILE="${CUSTOM_DIR}/configs/hack.conf"

DATETIME="$(date +%Y%m%d_%H%M%S)"
LOG_FILE="${LOGS_DIR}/run.${DATETIME}-${RANDOM}.log"

log() {
    if [ "${LOGS}" = "1" ]; then
        echo "[$(date +%Y-%m-%dT%H:%M:%S)] $*"
    fi
}

load_cfg() {
    # Defaults
    LOGS=1
    OVERRIDE_HW_SETTINGS=1
    OVERRIDE_SW_SETTINGS=0
    OVERRIDE_ANYKA_SETTINGS=0

    if [ -f "${CFG_FILE}" ]; then
        # shellcheck disable=SC1090
        . "${CFG_FILE}"
    fi
}

kill_processes() {
    sleep 30
    kill -9 "$(ps | grep -F 'drop_caches' | grep -v grep | awk '{print $1}')" || true
    rm /tmp/drop_caches.sh || true
    #kill -TERM "$(pidof anyka_ipc)" || true
    killall -9 anyka_ipc
}

ensure_shadow() {
    src="${SD_DIR}/shadow"
    dst="/etc/config/shadow"
    done="${LOGS_DIR}/shadow.done"

    [ -f "$done" ] && [ -f "$dst" ] && return 0

    log "Copying shadow..."
    touch "${dst}"
    mount --bind "${src}" "${dst}" || true

    : >"$done"
    log "Shadow copied."
}

apply_overrides() {
    if [ "${OVERRIDE_HW_SETTINGS}" = "1" ]; then
        mount --bind "${CONFIG_DIR}/_ht_hw_settings.ini" /etc/config/_ht_hw_settings.ini
    fi

    if [ "${OVERRIDE_SW_SETTINGS}" = "1" ]; then
        mount --bind "${CONFIG_DIR}/_ht_sw_settings.ini" /etc/config/_ht_sw_settings.ini
    fi

    if [ "${OVERRIDE_ANYKA_SETTINGS}" = "1" ]; then
        mount --bind "${CONFIG_DIR}/anyka_cfg.ini" /etc/config/anyka_cfg.ini
    fi

    ensure_shadow
    sync
}

show_info() {
    log "===================="
    log "------------ process"
    ps aux
    log "------------ /tmp"
    ls -a /tmp
    log "------------ netstat"
    netstat -tulpn
    log "===================="
}

main() {
    log "Checkin stuff pre-hack"
    show_info

    apply_overrides

    /bin/sh "${SCRIPTS_DIR}/sounds.sh" >/dev/null 2>&1 || true
    /bin/sh "${SCRIPTS_DIR}/entrypoint.sh" >/dev/null 2>&1 || true

    kill_processes

    log "Checkin stuff post-hack"
    show_info
}

## Script execution

mkdir -p "${SD_DIR}"
mount /dev/mmcblk0p1 "${SD_DIR}" || mount /dev/mmcblk0 "${SD_DIR}" || true

mkdir -p "${SD_DIR}/logs"
exec >>"${LOG_FILE}" 2>&1

load_cfg

log "hack.sh starting"
log "DATE IS: $(date)"
log "CFG=${CFG_FILE} exists=$([ -f "${CFG_FILE}" ] && echo yes || echo NO)"
head -3 "${CFG_FILE}" 2>/dev/null | sed 's/^/CFG> /'

main

log "hack.sh done"
