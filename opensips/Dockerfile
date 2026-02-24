# Multi-architecture OpenSIPS build
FROM debian:bookworm-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    gnupg2 \
    wget \
    ca-certificates \
    lsb-release \
    gettext-base \
    && rm -rf /var/lib/apt/lists/*

# Add OpenSIPS repository (supports multiple architectures)
RUN wget -qO - https://apt.opensips.org/opensips-org.gpg | apt-key add - \
    && echo "deb https://apt.opensips.org bookworm 3.4-releases" > /etc/apt/sources.list.d/opensips.list

# Install OpenSIPS with required modules
RUN apt-get update && apt-get install -y \
    opensips \
    opensips-tls-module \
    opensips-wss-module \
    opensips-rtpengine-module \
    opensips-db-sqlite-module \
    opensips-sqlite-module \
    && rm -rf /var/lib/apt/lists/*

# Copy configuration
COPY opensips.cfg /etc/opensips/opensips.cfg
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 443/tcp 5060/udp

ENTRYPOINT ["/entrypoint.sh"]
CMD ["opensips", "-F", "-E"]
