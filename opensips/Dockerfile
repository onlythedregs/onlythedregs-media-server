# Build from Debian base - opensips/opensips:3.4 is AMD64-only
FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    gnupg2 wget ca-certificates gettext-base \
    && rm -rf /var/lib/apt/lists/*

# Add official OpenSIPS repo (has ARM64 packages)
RUN wget -O /etc/apt/trusted.gpg.d/opensips.gpg \
        https://apt.opensips.org/opensips-org.gpg \
    && echo "deb https://apt.opensips.org bullseye 3.4-releases" \
        > /etc/apt/sources.list.d/opensips.list \
    && apt-get update \
    && apt-cache search opensips | sort \
    && apt-get install -y opensips \
    && rm -rf /var/lib/apt/lists/*

COPY opensips.cfg /etc/opensips/opensips.cfg
COPY entrypoint.sh /entrypoint.sh
RUN sed -i 's/\r//' /entrypoint.sh && chmod +x /entrypoint.sh

EXPOSE 443/tcp 5060/udp

ENTRYPOINT ["/entrypoint.sh"]
CMD ["opensips", "-F", "-E"]
