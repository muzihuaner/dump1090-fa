#!/bin/sh

set -ex

mkdir -p /run/dump1090

/usr/sbin/nginx -c /opt/dump1090/nginx.conf 2>/dev/null

# DEVICE_SERIAL 为空时自动使用第一个可用的 RTL-SDR 设备
if [ -n "${DEVICE_SERIAL:-}" ]; then
    exec /opt/dump1090/dump1090 --quiet --stats-every 60 --device "${DEVICE_SERIAL}" --net --write-json /run/dump1090
else
    exec /opt/dump1090/dump1090 --quiet --stats-every 60 --net --write-json /run/dump1090
fi
