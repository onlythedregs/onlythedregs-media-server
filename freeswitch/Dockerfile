# FreeSWITCH with video support for ARM64/x86_64
# Using Debian 12 (bookworm) which has better FreeSWITCH package support
FROM debian:bookworm-slim

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies and add SignalWire repository
RUN apt-get update && apt-get install -y \
    gnupg2 \
    wget \
    lsb-release \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Add SignalWire FreeSWITCH repository for Debian Bookworm
# Using the new SignalWire package cloud
RUN curl -fsSL https://freeswitch.signalwire.com/repo/deb/debian-release/signalwire-freeswitch-repo.gpg \
    | gpg --dearmor -o /usr/share/keyrings/signalwire-freeswitch-repo.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/signalwire-freeswitch-repo.gpg] https://freeswitch.signalwire.com/repo/deb/debian-release/ bookworm main" \
    > /etc/apt/sources.list.d/freeswitch.list

# Install FreeSWITCH
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
