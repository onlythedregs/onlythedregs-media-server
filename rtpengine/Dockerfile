# Multi-architecture RTPEngine build using Ubuntu 24.04 LTS
FROM ubuntu:24.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    gnupg2 \
    ca-certificates \
    gettext-base \
    curl \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Add RTPEngine repository for Ubuntu 24.04  
RUN wget -qO - https://dfx.at/rtpengine/gpg.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/rtpengine.gpg \
    && echo "deb https://dfx.at/rtpengine/ubuntu noble main" > /etc/apt/sources.list.d/rtpengine.list

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
