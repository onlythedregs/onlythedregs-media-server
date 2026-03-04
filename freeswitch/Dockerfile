# FreeSWITCH built from source - multi-arch (ARM64/AMD64)
# Based on: https://medium.com/@er.anil.ec/installing-freeswitch-from-source-using-docker-and-docker-compose-ed2cc4fa992e
FROM ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive
ENV PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/lib/pkgconfig
ENV PATH="/usr/local/freeswitch/bin:$PATH"

# Base build tools
RUN apt-get update && apt-get install -y \
    build-essential cmake git wget curl pkg-config \
    libtool libtool-bin autoconf automake bash \
    software-properties-common ca-certificates gnupg \
    yasm nasm

# Core dependencies
RUN apt-get install -y \
    libssl-dev libsqlite3-dev libcurl4-openssl-dev libpcre2-dev \
    libspeex-dev libspeexdsp-dev libldns-dev \
    uuid-dev libpq-dev libopus-dev libsndfile1-dev \
    libavformat-dev libavcodec-dev libavutil-dev libswscale-dev \
    libjpeg-dev libtiff-dev libedit-dev liblua5.3-dev \
    libswresample-dev libvpx-dev libavresample-dev \
    && rm -rf /var/lib/apt/lists/*

# Build sofia-sip from source (Debian/Ubuntu packages often too old)
RUN git clone https://github.com/freeswitch/sofia-sip.git /usr/src/sofia-sip \
    && cd /usr/src/sofia-sip \
    && ./bootstrap.sh \
    && ./configure --prefix=/usr/local \
    && make -j$(nproc) \
    && make install

# Build spandsp from source
RUN git clone https://github.com/freeswitch/spandsp.git /usr/src/spandsp \
    && cd /usr/src/spandsp \
    && ./bootstrap.sh \
    && ./configure --prefix=/usr/local \
    && make -j$(nproc) \
    && make install

# Clone FreeSWITCH source via git (bootstrap.sh requires git history)
RUN git clone --depth=1 --branch v1.10.11 https://github.com/signalwire/freeswitch.git /usr/src/freeswitch

WORKDIR /usr/src/freeswitch

RUN ./bootstrap.sh -j

RUN PKG_CONFIG_PATH=/usr/local/lib/pkgconfig CFLAGS="-O2" ./configure \
    --prefix=/usr/local/freeswitch \
    --with-openssl \
    --disable-debug

RUN make -j$(nproc) && make install

# ---

# Stage 2: Runtime
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/usr/local/freeswitch/bin:$PATH"

RUN apt-get update && apt-get install -y \
    libssl3 \
    libcurl4 \
    libpcre2-8-0 \
    libsqlite3-0 \
    libedit2 \
    liblua5.3-0 \
    libsndfile1 \
    libopus0 \
    libjpeg8 \
    libtiff5 \
    uuid-runtime \
    gettext-base \
    libavformat58 \
    libavcodec58 \
    libavutil56 \
    libswscale5 \
    libvpx7 \
    libspeex1 \
    libspeexdsp1 \
    && rm -rf /var/lib/apt/lists/*

# Copy FreeSWITCH and its dependencies from builder
COPY --from=builder /usr/local/freeswitch /usr/local/freeswitch
COPY --from=builder /usr/local/lib/libsofia* /usr/local/lib/
COPY --from=builder /usr/local/lib/libspandsp* /usr/local/lib/

RUN ldconfig

# Copy configuration files
COPY sip_profiles/ /usr/local/freeswitch/conf/sip_profiles/
COPY dialplan/ /usr/local/freeswitch/conf/dialplan/
COPY autoload_configs/ /usr/local/freeswitch/conf/autoload_configs/

RUN mkdir -p /videos

EXPOSE 5060/udp
EXPOSE 5060/tcp

CMD ["freeswitch", "-nonat", "-nc"]

# Copy configuration files
COPY sip_profiles/ /etc/freeswitch/sip_profiles/
COPY dialplan/ /etc/freeswitch/dialplan/
COPY autoload_configs/ /etc/freeswitch/autoload_configs/

# Create videos directory
RUN mkdir -p /videos

EXPOSE 5060/udp
EXPOSE 5060/tcp

CMD ["freeswitch", "-nonat", "-nc"]
