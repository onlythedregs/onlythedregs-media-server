# Multi-architecture OpenSIPS build using Ubuntu 24.04 LTS
FROM ubuntu:24.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies and OpenSIPS
RUN apt-get update && apt-get install -y \
    wget \
    gnupg2 \
    ca-certificates \
    gettext-base \
    && rm -rf /var/lib/apt/lists/*

# Add OpenSIPS repository for Ubuntu 24.04
RUN wget -qO - https://apt.opensips.org/opensips-org.gpg | gpg --dearmor > /etc/apt/trusted.gpg.d/opensips.gpg \
    && echo "deb https://apt.opensips.org noble 3.4-releases" > /etc/apt/sources.list.d/opensips.list

# Install OpenSIPS with required modules
RUN apt-get update && apt-get install -y \
    opensips \
    opensips-tls-module \
    opensips-wss-module \
    opensips-rtpengine-module \
    && rm -rf /var/lib/apt/lists/*

# Copy configuration
COPY opensips.cfg /etc/opensips/opensips.cfg
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 443/tcp 5060/udp

ENTRYPOINT ["/entrypoint.sh"]
CMD ["opensips", "-F", "-E"]
