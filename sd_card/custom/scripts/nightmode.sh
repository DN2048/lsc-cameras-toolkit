#!/bin/sh

SD_DIR="/tmp/sd"
LOG_FILE="${SD_DIR}/logs/nightmode.log"
CUSTOM_DIR="${SD_DIR}/custom"
CFG_FILE="${CUSTOM_DIR}/configs/hack.conf"
HW_CONF="${CUSTOM_DIR}/configs/_ht_hw_settings.ini"
HW_SYS_CONF=/etc/config/_ht_hw_settings.ini

load_cfg() {
    # Defaults
    NIGHT_MODE=1

    if [ -f "${CFG_FILE}" ]; then
        # shellcheck disable=SC1090
        . "${CFG_FILE}"
    fi
}

# The real knobs are [night_mode] ps_soft_day_to_night_lum / ps_soft_night_to_day_lum in _ht_hw_settings.ini.
set_values() {
    da="$1"
    db="$2"
    for F in "$HW_CONF" "$HW_SYS_CONF"; do
        [ -f "$F" ] || continue
        awk -v da="$da" -v db="$db" '{
      if ($0 ~ /^ps_soft_day_to_night_lum[ ]/)  { print "ps_soft_day_to_night_lum  = " da; next }
      if ($0 ~ /^ps_soft_night_to_day_lum[ ]/)  { print "ps_soft_night_to_day_lum  = " db; next }
      print
    }' "$F" >"$F.tmp" && cat "$F.tmp" >"$F" && rm -f "$F.tmp" 2>/dev/null
    done
}

# Script execution
load_cfg
exec >>"${LOG_FILE}" 2>&1

if [ "${NIGHT_MODE}" = "0" ]; then
    set_values 0 0
    log "Nightmode off. Always in normal vision even in darkness."
else
    set_values 6300000 2000000
    echo "Nightmode Auto: factory day/night (day_to_night=6300000, night_to_day=2000000) applied."
fi
