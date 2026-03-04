# FreeSWITCH using Debian bookworm official packages (multi-arch: ARM64/AMD64)
FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# Install FreeSWITCH directly from Debian's official repos - no external repo needed
RUN apt-get update && apt-get install -y \
    freeswitch \
    freeswitch-mod-commands \
    freeswitch-mod-console \
    freeswitch-mod-logfile \
    freeswitch-mod-sofia \
    freeswitch-mod-dialplan-xml \
    freeswitch-mod-dptools \
    freeswitch-mod-sndfile \
    freeswitch-mod-tone-stream \
    freeswitch-mod-g711 \
    freeswitch-mod-opus \
    gettext-base \
    && rm -rf /var/lib/apt/lists/*

# Copy configuration files
COPY sip_profiles/ /etc/freeswitch/sip_profiles/
COPY dialplan/ /etc/freeswitch/dialplan/
COPY autoload_configs/ /etc/freeswitch/autoload_configs/

# Create videos directory
RUN mkdir -p /videos

EXPOSE 5060/udp
EXPOSE 5060/tcp

CMD ["freeswitch", "-nonat", "-nc"]
