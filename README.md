# The macchina.io Remote Manager Device Agent Docker Image

## About macchina.io Remote Manager

[macchina.io Remote Manager](https://macchina.io) provides secure remote access to connected devices
via HTTP or other TCP-based protocols and applications such as secure shell (SSH) or
Virtual Network Computing (VNC). With macchina.io Remote Manager, any network-connected device
running the Remote Manager Agent software (*WebTunnelAgent*, contained in this SDK)
can be securely accessed remotely over the internet from browsers, mobile apps, desktop,
server or cloud applications.

This even works if the device is behind a NAT router, firewall or proxy server.
The device becomes just another host on the internet, addressable via its own URL and
protected by the Remote Manager server against unauthorized or malicious access.
macchina.io Remote Manager is a great solution for secure remote support and maintenance,
as well as for providing secure remote access to devices for end-users via web or
mobile apps.

Visit [macchina.io](https://macchina.io/remote.html) to learn more and to register for a free account.
Specifically, see the [Getting Started](https://macchina.io/remote_signup.html) page and the
[Frequently Asked Questions](https://macchina.io/remote_faq.html) for
information on how to use the macchina.io Remote Manager device agent.

There is also a [blog post](https://macchina.io/blog/?p=257) showing step-by-step instructions to connect a Raspberry Pi.

## About This Docker Image

This repository contains a [Dockerfile](Dockerfile) and related files for building and running
the [WebTunnelAgent](https://github.com/my-devices/sdk/blob/master/WebTunnel/WebTunnelAgent/README.md)
device agent from the
[macchina.io Remote Manager SDK](https://github.com/my-devices/sdk) in a Docker container.

The image comes with a configuration file ([WebTunnelAgent.properties](WebTunnelAgent.properties)) that allows
configuring the most essential settings via environment variables.
The following environment variables are supported:

  - `WEBTUNNEL_DOMAIN`: The domain (UUID) of the device. Must be specified.
  - `WEBTUNNEL_DEVICE_ID`: The device ID to use. Must be specified.
  - `WEBTUNNEL_DEVICE_NAME`: The device name shown in the web user interface. Defaults to `Unnamed Device`.
  - `WEBTUNNEL_HOST`: The target host the agents forwards incoming tunneled connections to. Defaults to `127.0.0.1`.
  - `WEBTUNNEL_HTTP_PORT`: The port number of the device's web server. Defaults to 80. Set to 0 to disable HTTP access.
  - `WEBTUNNEL_HTTPS_ENABLE`: Set to `true` if device web server requires HTTPS instead of HTTP. Defaults to `false`.
  - `WEBTUNNEL_SSH_PORT`: The port number of the device's SSH server. Defaults to 0 (disabled).
  - `WEBTUNNEL_VNC_PORT`: The port number of the device's VNC server. Defaults to 0 (disabled).
  - `WEBTUNNEL_RDP_PORT`: The port number of the device's RDP server. Defaults to 0 (disabled).
  - `WEBTUNNEL_REFLECTOR_URI`: The address of the macchina.io Remote Manager Server (*reflector*).
    Default: https://reflector.my-devices.net
  - `WEBTUNNEL_PASSWORD`: Optional device password. Defaults to none.
  - `LOGPATH`: Path to the log file (defaults to `/var/log/WebTunnelAgent.log`); can be
    overridden to log to a different file (e.g. in a volume). Note: `LOGCHANNEL` must
    be set to `file` for the logfile to be written.
  - `LOGLEVEL`: Specifies the log level (`debug`, `information`, `notice`, `warning`,
    `error`, `critical`, `fatal`, `none`). Defaults to `information`.
  - `LOGCHANNEL`: Specifies where log messages go (`file` or `console`). Defaults to `console`.

## Prerequisites

  - Docker

## Building

```
$ docker build . -t macchina/device-agent
```

## Running

The device agent must be able to connect to the device's web server and/or any other services
that are to be forwarded. So when running the container, an appropriate network configuration
for the container must be set up. The easiest way is to run with *host* networking.

```
$ docker run -e WEBTUNNEL_DOMAIN=eac8b99b-1866-4ef4-8f57-76b655949c29 -e WEBTUNNEL_DEVICE_ID=6e26e894-10a2-48bf-80f1-65a48527c80e -e WEBTUNNEL_HTTP_PORT=8080 -e WEBTUNNEL_SSH_PORT=22 --network host macchina/device-agent
```

You must replace the values for `WEBTUNNEL_DOMAIN` and `WEBTUNNEL_DEVICE_ID` with your specific values.

## Configuration

The most important configuration settings can be set via environment variables (see above).
If you need to change other configuration options, edit [WebTunnelAgent.properties](WebTunnelAgent.properties)
and rebuild the Docker image.
For a description of all available configuration settings, see the
[WebTunnelAgent README](https://github.com/my-devices/sdk/blob/master/WebTunnel/WebTunnelAgent/README.md).
