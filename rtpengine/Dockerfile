# Multi-architecture RTPEngine build
FROM debian:bookworm-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    gnupg2 \
    wget \
    ca-certificates \
    lsb-release \
    gettext-base \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Add RTPEngine repository (supports multiple architectures)
RUN wget -qO - https://dfx.at/rtpengine/gpg.asc | apt-key add - \
    && echo "deb https://dfx.at/rtpengine/debian $(lsb_release -sc) main" > /etc/apt/sources.list.d/rtpengine.list

# Install RTPEngine 
RUN apt-get update && apt-get install -y \
    rtpengine \
    && rm -rf /var/lib/apt/lists/*

# Copy configuration
COPY rtpengine.conf /etc/rtpengine/rtpengine.conf
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 2223/udp
EXPOSE 10000-20000/udp

ENTRYPOINT ["/entrypoint.sh"]
