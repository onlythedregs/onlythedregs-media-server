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
    gettext autopoint gawk \
    yasm nasm \
    && ln -sf /usr/bin/libtool /usr/local/bin/libtool \
    && ln -sf /usr/bin/libtoolize /usr/local/bin/libtoolize

# Core dependencies
RUN apt-get install -y \
    libssl-dev libsqlite3-dev libcurl4-openssl-dev \
    libpcre3-dev \
    libspeex-dev libspeexdsp-dev libldns-dev \
    uuid-dev libpq-dev libopus-dev libsndfile1-dev \
    libjpeg-dev libtiff-dev libpng-dev libedit-dev liblua5.3-dev \
    && rm -rf /var/lib/apt/lists/*

# Build sofia-sip from source (Debian/Ubuntu packages often too old)
RUN git clone https://github.com/freeswitch/sofia-sip.git /usr/src/sofia-sip \
    && cd /usr/src/sofia-sip \
    && ./bootstrap.sh \
    && ./configure --prefix=/usr/local \
    && make -j$(nproc) \
    && make install

# Build libks from source (required by mod_verto in FreeSWITCH 1.10.x)
RUN git clone https://github.com/signalwire/libks.git /usr/src/libks \
    && cd /usr/src/libks \
    && cmake . -DCMAKE_INSTALL_PREFIX=/usr/local \
    && make -j$(nproc) \
    && make install
# cmake may install to lib64 on some arches; copy to lib so configure/ldconfig finds it
RUN find /usr/local/lib64 -name 'libks*' -exec cp {} /usr/local/lib/ \; 2>/dev/null || true

# Clone FreeSWITCH source via git (bootstrap.sh requires git history)
RUN git clone --depth=1 --branch v1.10.11 https://github.com/signalwire/freeswitch.git /usr/src/freeswitch

WORKDIR /usr/src/freeswitch

# Verify libtool is visible before bootstrap
RUN which libtool && libtool --version
RUN ./bootstrap.sh 2>&1 | tee /tmp/bootstrap.log || (echo "=== BOOTSTRAP LOG ===" && cat /tmp/bootstrap.log && exit 1)

# Disable modules we don't need / have missing/broken deps for
RUN sed -i \
    -e 's|^applications/mod_signalwire|#applications/mod_signalwire|' \
    -e 's|^applications/mod_spandsp|#applications/mod_spandsp|' \
    -e 's|^applications/mod_av|#applications/mod_av|' \
    -e 's|^codecs/mod_h264|#codecs/mod_h264|' \
    -e 's|^codecs/mod_vp8|#codecs/mod_vp8|' \
    -e 's|^formats/mod_png|#formats/mod_png|' \
    modules.conf

RUN PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/local/lib64/pkgconfig:/usr/lib/pkgconfig:/usr/lib/x86_64-linux-gnu/pkgconfig:/usr/lib/aarch64-linux-gnu/pkgconfig CFLAGS="-O2" ./configure \
    --prefix=/usr/local/freeswitch \
    --with-openssl \
    --without-spandsp \
    --disable-debug

RUN make -j$(nproc) > /tmp/make.log 2>&1 \
    || (echo "=== MAKE FAILED ===" && tail -80 /tmp/make.log && exit 1)
RUN make install

# ---

# Stage 2: Runtime
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/usr/local/freeswitch/bin:$PATH"

RUN apt-get update && apt-get install -y \
    libssl3 \
    libcurl4 \
    libpcre3 \
    libsqlite3-0 \
    libedit2 \
    liblua5.3-0 \
    libsndfile1 \
    libopus0 \
    libjpeg8 \
    libtiff5 \
    uuid-runtime \
    gettext-base \
    libspeex1 \
    libspeexdsp1 \
    libpng16-16 \
    && rm -rf /var/lib/apt/lists/*

# Copy FreeSWITCH and its dependencies from builder
COPY --from=builder /usr/local/freeswitch /usr/local/freeswitch
COPY --from=builder /usr/local/lib/libsofia* /usr/local/lib/
COPY --from=builder /usr/local/lib/libks* /usr/local/lib/

RUN ldconfig

# Copy configuration files
COPY sip_profiles/ /usr/local/freeswitch/conf/sip_profiles/
COPY dialplan/ /usr/local/freeswitch/conf/dialplan/
COPY autoload_configs/ /usr/local/freeswitch/conf/autoload_configs/

RUN mkdir -p /videos

EXPOSE 5060/udp
EXPOSE 5060/tcp

CMD ["freeswitch", "-nonat", "-nc"]
