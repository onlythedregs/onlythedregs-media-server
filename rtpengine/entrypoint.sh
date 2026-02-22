#!/bin/bash
set -e

# Get public IP if not set
if [ -z "$PUBLIC_IP" ]; then
    PUBLIC_IP=$(curl -s ifconfig.me || echo "127.0.0.1")
fi

# Substitute environment variables
export PUBLIC_IP
envsubst < /etc/rtpengine/rtpengine.conf > /etc/rtpengine/rtpengine.conf.tmp
mv /etc/rtpengine/rtpengine.conf.tmp /etc/rtpengine/rtpengine.conf

exec rtpengine --config-file=/etc/rtpengine/rtpengine.conf --foreground
