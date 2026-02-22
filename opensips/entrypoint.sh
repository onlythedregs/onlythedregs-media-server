#!/bin/bash
set -e

# Substitute environment variables in config
envsubst < /etc/opensips/opensips.cfg > /etc/opensips/opensips.cfg.tmp
mv /etc/opensips/opensips.cfg.tmp /etc/opensips/opensips.cfg

exec "$@"
