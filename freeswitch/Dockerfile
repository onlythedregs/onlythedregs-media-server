# FreeSWITCH using SignalWire's official multi-arch image
FROM signalwire/freeswitch-public-base:bookworm

# Remove SignalWire repo (requires auth) and install gettext from Debian repos
RUN rm -f /etc/apt/sources.list.d/freeswitch*.list /etc/apt/sources.list.d/signalwire*.list 2>/dev/null || true \
    && apt-get update && apt-get install -y \
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
