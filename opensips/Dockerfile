# Mirror official docker-opensips Dockerfile (debian:bullseye base)
# opensips/opensips:3.4 is AMD64-only; this approach supports ARM64
FROM debian:bullseye-slim

LABEL maintainer="onlythedregs"

USER root
ENV DEBIAN_FRONTEND=noninteractive

ARG OPENSIPS_VERSION=3.4
ARG OPENSIPS_BUILD=releases

RUN apt-get -y update -qq && apt-get -y install \
    gnupg2 ca-certificates gettext-base wget \
    && rm -rf /var/lib/apt/lists/*

# Add OpenSIPS apt repo (same method as official docker-opensips)
RUN apt-key adv --fetch-keys https://apt.opensips.org/pubkey.gpg \
    && echo "deb https://apt.opensips.org bullseye ${OPENSIPS_VERSION}-${OPENSIPS_BUILD}" \
        > /etc/apt/sources.list.d/opensips.list \
    && apt-get -y update -qq \
    && apt-get -y install \
        opensips \
        opensips-tls-module \
        opensips-wss-module \
        opensips-rtpengine-module \
    && rm -rf /var/lib/apt/lists/*

COPY opensips.cfg /etc/opensips/opensips.cfg
COPY entrypoint.sh /entrypoint.sh
RUN sed -i 's/\r//' /entrypoint.sh && chmod +x /entrypoint.sh

EXPOSE 443/tcp 5060/udp

ENTRYPOINT ["/entrypoint.sh"]
CMD ["opensips", "-F", "-E"]
