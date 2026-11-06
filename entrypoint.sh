#!/bin/sh

set -ex

mkdir -p /run/dump1090

/usr/sbin/nginx -c /opt/dump1090/nginx.conf 2>/dev/null

RECEIVER="${RECEIVER:-rtlsdr}"

if [ "${RECEIVER}" != "rtlsdr" ]; then
    echo "Unsupported RECEIVER: ${RECEIVER} (only rtlsdr is supported)" >&2
    exit 1
fi

set -- --quiet --stats-every 60 --net --write-json /run/dump1090

if [ -n "${RECEIVER_LAT:-}" ]; then
    set -- "$@" --lat "${RECEIVER_LAT}"
fi

if [ -n "${RECEIVER_LON:-}" ]; then
    set -- "$@" --lon "${RECEIVER_LON}"
fi

# DEVICE_SERIAL 为空时自动使用第一个可用的 RTL-SDR 设备
if [ -n "${DEVICE_SERIAL:-}" ]; then
    set -- "$@" --device "${DEVICE_SERIAL}"
fi

exec /opt/dump1090/dump1090 "$@"
