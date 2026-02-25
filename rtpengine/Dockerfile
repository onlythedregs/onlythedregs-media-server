# RTPEngine using jambonz official Docker image
FROM jambonz/rtpengine:latest

# Install gettext for environment variable substitution
USER root
RUN apt-get update && apt-get install -y \
    gettext-base \
    && rm -rf /var/lib/apt/lists/*

# Copy configuration
COPY rtpengine.conf /etc/rtpengine/rtpengine.conf
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 2223/udp
EXPOSE 10000-20000/udp

ENTRYPOINT ["/entrypoint.sh"]
