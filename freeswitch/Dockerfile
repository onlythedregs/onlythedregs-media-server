FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive

# Prerequisites for repo setup
RUN apt-get update && apt-get install -y \
    gnupg2 wget lsb-release gettext-base \
    && rm -rf /var/lib/apt/lists/*

# Add SignalWire FreeSWITCH repo using secret token (never cached in image layers)
RUN --mount=type=secret,id=sw_token \
    TOKEN=$(cat /run/secrets/sw_token) \
    && wget --http-user=signalwire --http-password="$TOKEN" \
        -O /etc/apt/trusted.gpg.d/signalwire-freeswitch-repo.gpg \
        https://freeswitch.signalwire.com/repo/deb/debian-release/signalwire-freeswitch-repo.gpg \
    && echo "machine freeswitch.signalwire.com login signalwire password $TOKEN" \
        > /etc/apt/auth.conf \
    && chmod 600 /etc/apt/auth.conf \
    && echo "deb [signed-by=/etc/apt/trusted.gpg.d/signalwire-freeswitch-repo.gpg] https://freeswitch.signalwire.com/repo/deb/debian-release/ bullseye main" \
        > /etc/apt/sources.list.d/freeswitch.list \
    && apt-get update \
    && apt-get install -y freeswitch-meta-all \
    && rm -rf /var/lib/apt/lists/* /etc/apt/auth.conf

COPY sip_profiles/ /etc/freeswitch/sip_profiles/
COPY dialplan/ /etc/freeswitch/dialplan/
COPY autoload_configs/ /etc/freeswitch/autoload_configs/

RUN mkdir -p /videos

EXPOSE 5060/udp
EXPOSE 5060/tcp

CMD ["freeswitch", "-nonat", "-nc"]
