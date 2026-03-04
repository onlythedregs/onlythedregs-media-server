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
    curl \
    gnupg2 \
    libssl-dev \
    libcurl4-openssl-dev \
    libpcre3-dev \
    libsqlite3-dev \
    libedit-dev \
    libsndfile1-dev \
    libopus-dev \
    libogg-dev \
    libvorbis-dev \
    libspeex-dev \
    libspeexdsp-dev \
    libjpeg-dev \
    libldns-dev \
    zlib1g-dev \
    libspandsp-dev \
    libsofia-sip-ua-dev \
    libgsm1-dev \
    libtiff-dev \
    uuid-dev \
    libxmlrpc-core-c3-dev \
    libyaml-dev \
    libmemcached-dev \
    libhiredis-dev \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Install libks (SignalWire's required library for FreeSWITCH 1.10.x)
RUN git clone https://github.com/signalwire/libks.git /usr/src/libks \
    && cd /usr/src/libks \
    && cmake . -DCMAKE_INSTALL_PREFIX=/usr \
    && make -j$(nproc) \
    && make install

# Install signalwire-c (another SignalWire dependency)
RUN git clone https://github.com/signalwire/signalwire-c.git /usr/src/signalwire-c \
    && cd /usr/src/signalwire-c \
    && cmake . -DCMAKE_INSTALL_PREFIX=/usr \
    && make -j$(nproc) \
    && make install

# Download FreeSWITCH source
WORKDIR /usr/src
RUN wget -q https://github.com/signalwire/freeswitch/archive/refs/tags/v1.10.11.tar.gz \
    && tar -xzf v1.10.11.tar.gz \
    && mv freeswitch-1.10.11 freeswitch \
    && rm v1.10.11.tar.gz

WORKDIR /usr/src/freeswitch

# Bootstrap
RUN ./bootstrap.sh -j

# Configure - disable av/video modules to avoid ffmpeg ARM issues
RUN CFLAGS="-O2" ./configure \
    --prefix=/usr \
    --sysconfdir=/etc/freeswitch \
    --localstatedir=/var \
    --with-openssl \
    --disable-debug \
    --disable-mod_av \
    --disable-mod_ffmpeg \
    2>&1 | tee /tmp/configure.log || (cat /tmp/configure.log && exit 1)

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
COPY --from=builder /usr/lib/libks* /usr/lib/
COPY --from=builder /usr/lib/libsignalwire* /usr/lib/

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
