#!/bin/sh
set -e

# Substitute environment variables in config
envsubst < /etc/kamailio/kamailio.cfg > /etc/kamailio/kamailio.cfg.tmp
mv /etc/kamailio/kamailio.cfg.tmp /etc/kamailio/kamailio.cfg

exec "$@"
