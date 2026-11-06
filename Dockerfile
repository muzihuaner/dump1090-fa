FROM ubuntu:24.04 AS builder

RUN --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    apt-get update && apt-get install --no-install-recommends --assume-yes \
    ca-certificates \
    git \
    build-essential \
    lighttpd \
    debhelper \
    pkg-config \
    librtlsdr-dev \
    libncurses-dev 

RUN git clone https://github.com/flightaware/dump1090.git -b v9.0

WORKDIR /dump1090

RUN make

FROM ubuntu:24.04

RUN --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    apt-get update && apt-get install --no-install-recommends --assume-yes \
    language-pack-zh-hans \
    tzdata \
    librtlsdr2 \
    libncurses6 \
    nginx

ENV TZ=Asia/Shanghai \
    LANG=zh_CN.UTF-8 \
    LANGUAGE=zh_CN:zh \
    LC_ALL=zh_CN.UTF-8

RUN locale-gen en_US.UTF-8
RUN locale-gen zh_CN.UTF-8

COPY --from=builder dump1090 /opt/dump1090

COPY conf/nginx.conf /opt/dump1090
COPY entrypoint.sh /opt/dump1090

RUN echo '{"type": "dump1090-fa"}' > /opt/dump1090/public_html/status.json

EXPOSE 8080 30001 30002 30003

ENTRYPOINT ["/opt/dump1090/entrypoint.sh"]
