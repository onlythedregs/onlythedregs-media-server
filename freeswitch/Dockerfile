# FreeSwitch with video support for ARM64/x86_64
FROM ubuntu:24.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    gnupg2 \
    wget \
    lsb-release \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Add FreeSWITCH repository - use jammy packages on noble (compatibility)
RUN wget -qO - https://files.freeswitch.org/repo/deb/debian-release/fsstretch-archive-keyring.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/freeswitch.gpg \
    && echo "deb http://files.freeswitch.org/repo/deb/debian-release/ jammy main" > /etc/apt/sources.list.d/freeswitch.list

# Install FreeSWITCH with video support
RUN apt-get update && apt-get install -y \
    freeswitch \
    freeswitch-mod-commands \
    freeswitch-mod-console \
    freeswitch-mod-logfile \
    freeswitch-mod-sofia \
    freeswitch-mod-dialplan-xml \
    freeswitch-mod-dptools \
    freeswitch-mod-expr \
    freeswitch-mod-sndfile \
    freeswitch-mod-native-file \
    freeswitch-mod-tone-stream \
    freeswitch-mod-flite \
    freeswitch-mod-g711 \
    freeswitch-mod-opus \
    freeswitch-mod-av \
    freeswitch-mod-png \
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
