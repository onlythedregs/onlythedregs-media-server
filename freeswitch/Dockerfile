# FreeSWITCH built from source - multi-arch (ARM64/AMD64)
# Stage 1: Build
FROM debian:bookworm AS builder

ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    automake \
    autoconf \
    libtool \
    pkg-config \
    git \
    wget \
    libssl-dev \
    libcurl4-openssl-dev \
    libpcre3-dev \
    libsqlite3-dev \
    libedit-dev \
    liblua5.2-dev \
    libsndfile1-dev \
    libopus-dev \
    libogg-dev \
    libvorbis-dev \
    libspeex-dev \
    libspeexdsp-dev \
    libjpeg-dev \
    libavformat-dev \
    libavcodec-dev \
    libavutil-dev \
    libswscale-dev \
    libswresample-dev \
    libldns-dev \
    zlib1g-dev \
    libspandsp-dev \
    libsofia-sip-ua-dev \
    libgsm1-dev \
    libtiff-dev \
    uuid-dev \
    && rm -rf /var/lib/apt/lists/*

# Download FreeSWITCH source
WORKDIR /usr/src
RUN wget -q https://github.com/signalwire/freeswitch/archive/refs/tags/v1.10.11.tar.gz \
    && tar -xzf v1.10.11.tar.gz \
    && mv freeswitch-1.10.11 freeswitch \
    && rm v1.10.11.tar.gz

WORKDIR /usr/src/freeswitch

# Bootstrap and configure
RUN ./bootstrap.sh -j

RUN ./configure \
    --prefix=/usr \
    --sysconfdir=/etc/freeswitch \
    --localstatedir=/var \
    --with-openssl \
    --disable-debug \
    CFLAGS="-O2"

# Build and install into staging directory
RUN make -j$(nproc) && make DESTDIR=/staging install

# ---

# Stage 2: Runtime
FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# Install only runtime dependencies
RUN apt-get update && apt-get install -y \
    libssl3 \
    libcurl4 \
    libpcre3 \
    libsqlite3-0 \
    libedit2 \
    liblua5.2-0 \
    libsndfile1 \
    libopus0 \
    libogg0 \
    libvorbis0a \
    libspeex1 \
    libspeexdsp1 \
    libspandsp2 \
    libsofia-sip-ua0 \
    libgsm1 \
    libtiff6 \
    uuid-runtime \
    gettext-base \
    && rm -rf /var/lib/apt/lists/*

# Copy built FreeSWITCH from builder stage
COPY --from=builder /staging /

# Copy configuration files
COPY sip_profiles/ /etc/freeswitch/sip_profiles/
COPY dialplan/ /etc/freeswitch/dialplan/
COPY autoload_configs/ /etc/freeswitch/autoload_configs/

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
