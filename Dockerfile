#
# This is the Dockerfile for the macchina.io REMOTE Device Agent (WebTunnelAgent)
#

#
# Stage 1: Build
#
FROM alpine:3.21 AS buildstage

# Install required components for building
RUN apk update \
 && apk add \
 	git \
    g++ \
    linux-headers \
    cmake \
    make \
    openssl-dev

# Build SDK/WebTunnelAgent
RUN mkdir -p build \
	&& cd build \
	&& git clone https://github.com/my-devices/sdk.git \
	&& cd sdk \
	&& mkdir cmake-build \
	&& cd cmake-build \
	&& cmake .. -DENABLE_WEBTUNNELCLIENT=OFF -DENABLE_WEBTUNNELSSH=OFF -DENABLE_WEBTUNNELSCP=OFF -DENABLE_WEBTUNNELSFTP=OFF -DENABLE_WEBTUNNELVNC=OFF -DENABLE_WEBTUNNELRDP=OFF \
	&& cmake --build . --config Release \
	&& strip bin/WebTunnelAgent

#
# Stage 2: Install
#
FROM alpine:3.21 AS runstage

RUN apk update \
 && apk add \
    libstdc++ \
    openssl \
    ca-certificates

# Copy WebTunnelAgent executable
COPY --from=buildstage /build/sdk/cmake-build/bin/WebTunnelAgent /usr/local/bin
ADD WebTunnelAgent.properties /etc/WebTunnelAgent.properties

ENV LOGPATH=/var/log/WebTunnelAgent.log
ENV LOGLEVEL=information
ENV LOGCHANNEL=console
ENV WEBTUNNEL_DOMAIN=00000000-0000-0000-0000-000000000000
ENV WEBTUNNEL_DEVICE_ID=00000000-0000-0000-0000-000000000000
ENV WEBTUNNEL_DEVICE_NAME="Unnamed Device"
ENV WEBTUNNEL_HOST=172.17.0.1
ENV WEBTUNNEL_HTTPS_ENABLE=false
ENV WEBTUNNEL_HTTP_PORT=80
ENV WEBTUNNEL_SSH_PORT=0
ENV WEBTUNNEL_VNC_PORT=0
ENV WEBTUNNEL_RDP_PORT=0
ENV WEBTUNNEL_APP_PORT=0
ENV WEBTUNNEL_EXTRA_PORTS=
ENV WEBTUNNEL_REFLECTOR_URI=https://remote.macchina.io
ENV WEBTUNNEL_PASSWORD=
ENV WEBTUNNEL_CONNECT_TIMEOUT=10
ENV WEBTUNNEL_LOCAL_TIMEOUT=7200
ENV WEBTUNNEL_REMOTE_TIMEOUT=300

CMD ["/usr/local/bin/WebTunnelAgent", "--config=/etc/WebTunnelAgent.properties"]
