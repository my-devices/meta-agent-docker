#
# This is the Dockerfile for the macchina.io Remote Manager Device Agent (WebTunnelAgent)
#

#
# Stage 1: Build
#
FROM ubuntu:18.04 as buildstage

# Install required components for building
RUN apt-get -y update \
 && apt-get -y install \
 	git \
    g++ \
    libssl-dev \
    cmake

# Build SDK/WebTunnelAgent
RUN mkdir -p build \
	&& cd build \
	&& git clone https://github.com/my-devices/sdk.git \
	&& cd sdk \
	&& mkdir cmake-build \
	&& cd cmake-build \
	&& cmake .. \
	&& cmake --build . --config Release

#
# Stage 2: Install
#
FROM ubuntu:18.04 as runstage

RUN apt-get -y update \
 && apt-get -y install \
    libssl1.1 \
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
ENV WEBTUNNEL_HOST=127.0.0.1
ENV WEBTUNNEL_HTTPS_ENABLE=false
ENV WEBTUNNEL_HTTP_PORT=80
ENV WEBTUNNEL_SSH_PORT=0
ENV WEBTUNNEL_VNC_PORT=0
ENV WEBTUNNEL_RDP_PORT=0
ENV WEBTUNNEL_REFLECTOR_URI=https://reflector.my-devices.net/
ENV WEBTUNNEL_PASSWORD=

CMD ["/usr/local/bin/WebTunnelAgent", "--config=/etc/WebTunnelAgent.properties"]
