FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# Kamailio is in the official Debian repos with ARM64 support
RUN apt-get update && apt-get install -y \
    kamailio \
    kamailio-tls-modules \
    kamailio-websocket-modules \
    kamailio-extra-modules \
    gettext-base \
    && rm -rf /var/lib/apt/lists/*

COPY kamailio.cfg /etc/kamailio/kamailio.cfg
COPY entrypoint.sh /entrypoint.sh
RUN sed -i 's/\r//' /entrypoint.sh && chmod +x /entrypoint.sh

EXPOSE 443/tcp 5060/udp

ENTRYPOINT ["/entrypoint.sh"]
CMD ["kamailio", "-DD", "-E"]
