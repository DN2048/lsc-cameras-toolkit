#!/bin/sh

SD_DIR="/tmp/sd"
LOG_FILE="${SD_DIR}/logs/sounds.log"
CUSTOM_DIR="${SD_DIR}/custom"
CFG_FILE="${CUSTOM_DIR}/configs/hack.conf"
SILENT_FILE="${CUSTOM_DIR}/audio/silent.mp3"

load_cfg() {
    # Defaults
    # Default on: factory mode boot prompt is very loud.
    MUTE_FACTORY_PROMPT=1
    MUTE_ALL_SOUNDS=0

    if [ -f "${CFG_FILE}" ]; then
        # shellcheck disable=SC1090
        . "${CFG_FILE}"
    fi
}

apply_factory_sound_mute() {
    for f in \
        /usr/share/hutong_sound2.mp3 \
        /usr/share/8k16_cn_factory_enter_factory_mode.mp3 \
        /usr/share/8k16_cn_factory_speaker_test_voice.mp3; do
        if [ -f "$f" ]; then
            mount --bind "${SILENT_FILE}" "$f" || true
            log "Muted factory prompt file: $f"
        fi
    done
}

mute_all() {
    for f in /usr/share/*.mp3; do
        if [ -f "$f" ]; then
            mount --bind "${SILENT_FILE}" "$f" || true
            log "Muted audio file: $f"
        fi
    done
}

load_cfg
exec >>"${LOG_FILE}" 2>&1

if [ "${MUTE_ALL_SOUNDS}" = "1" ]; then
  mute_all
elif [ "${MUTE_FACTORY_PROMPT}" = "1" ]; then
  apply_factory_sound_mute
fi
