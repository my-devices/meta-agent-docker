#
# This is the Dockerfile for the macchina.io REMOTE Device Agent (WebTunnelAgent)
#

#
# Stage 1: Build
#
FROM alpine:3.12 AS buildstage

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
	&& cmake .. -DENABLE_WEBTUNNELCLIENT=OFF -DENABLE_WEBTUNNELSSH=OFF -DENABLE_WEBTUNNELVNC=OFF -DENABLE_WEBTUNNELRDP=OFF \
	&& cmake --build . --config Release \
	&& strip bin/WebTunnelAgent

#
# Stage 2: Install
#
FROM alpine:3.12 as runstage

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
ENV WEBTUNNEL_REFLECTOR_URI=https://reflector.my-devices.net/
ENV WEBTUNNEL_PASSWORD=

CMD ["/usr/local/bin/WebTunnelAgent", "--config=/etc/WebTunnelAgent.properties"]
