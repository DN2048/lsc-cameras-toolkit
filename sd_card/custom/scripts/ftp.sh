#!/bin/sh
SD_DIR="/tmp/sd"
CUSTOM_DIR="${SD_DIR}/custom"
LOG_FILE="${SD_DIR}/logs/ftp.log"
CFG_FILE="${CUSTOM_DIR}/configs/hack.conf"
LOCK="/tmp/ftp.sh.pid"

# Wait for the sd
N=0
while [ ! -d "${CUSTOM_DIR}" ]; do
    if [ "$N" -ge 60 ]; then
        echo "SD never appeared; FTP not started" >&2
        exit 1
    fi
    sleep 1
    N=$((N+1))
done

if [ "${LOGS}" = "1" ]; then
    mkdir -p "${SD_DIR}/logs" >/dev/null 2>&1 || true
    touch "${LOG_FILE}"
    exec >>"${LOG_FILE}" 2>&1
fi

log() {
    if [ "${LOGS}" = "1" ]; then
        echo "[$(date +%Y-%m-%dT%H:%M:%S)] $*" >> "${LOG_FILE}"
    fi
}

load_cfg() {
    # Defaults
    LOGS=1
    FTP=0
    FTP_PORT=21

    if [ -f "${CFG_FILE}" ]; then
        # shellcheck disable=SC1090
        . "${CFG_FILE}"
    fi
}

run_ftp() {
    # This busybox build: -w=writable, -S=chroot DIR, -a USER=anonymous-as.
    # chroot is CAPPED to the SD card (safe default): anonymous FTP users can
    # only read/write files under the SD (/tmp/sd = /dev/mmcblk0p1), never the
    # rest of the camera's filesystem.
    #
    # TO EXPOSE THE WHOLE FILESYSTEM: change "-S /tmp/sd" to "-S /".
    # Warning: This gives anonymous root-level read/write of EVERY file on the camera
    setsid tcpsvd 0 "${FTP_PORT}" ftpd -w -S /tmp/sd -a root -t 1800  </dev/null &
    log "ftp started on port ${FTP_PORT}"
}

ensure_ftp() {
  while :; do
    if ps | grep -v grep | grep -q "tcpsvd 0 ${FTP_PORT}"; then
      sleep 2
      continue
    fi
    run_ftp
    sleep 1
  done
}

load_cfg

if [ "${FTP}" = "1" ]; then
    # Already-running guard (same as telnet.sh): if another live ftp.sh loop is up, do not start a second one.
    if [ -f "$LOCK" ] && kill -0 "$(cat "$LOCK" 2>/dev/null)" 2>/dev/null; then
      exit 0
    fi
    echo $$ > "$LOCK"
    ensure_ftp
fi
