# The macchina.io REMOTE Device Agent Docker Image

## About macchina.io REMOTE

[macchina.io REMOTE](https://macchina.io/remote) provides secure remote access to connected devices
via HTTP or other TCP-based protocols and applications such as secure shell (SSH) or
Virtual Network Computing (VNC). With macchina.io REMOTE, any network-connected device
running the macchina.io REMOTE Agent software (*WebTunnelAgent*, contained in this SDK)
can be securely accessed remotely over the internet from browsers, mobile apps, desktop,
server or cloud applications.

This even works if the device is behind a NAT router, firewall or proxy server.
The device becomes just another host on the internet, addressable via its own URL and
protected by the macchina.io REMOTE server against unauthorized or malicious access.
macchina.io REMOTE is a great solution for secure remote support and maintenance,
as well as for providing secure remote access to devices for end-users via web or
mobile apps.

Visit [macchina.io/remote](https://macchina.io/remote) to learn more and to register for a free account.
Specifically, see the [Getting Started](https://macchina.io/remote_signup.html) page and the
[Frequently Asked Questions](https://macchina.io/remote_faq.html) for
information on how to use the macchina.io REMOTE device agent.

There is also a [blog post](https://macchina.io/blog/?p=257) showing step-by-step instructions to connect a Raspberry Pi.

## About This Docker Image

This repository contains a [Dockerfile](Dockerfile) and related files for building and running
the [WebTunnelAgent](https://github.com/my-devices/sdk/blob/master/WebTunnel/WebTunnelAgent/README.md)
device agent from the
[macchina.io REMOTE SDK](https://github.com/my-devices/sdk) in a Docker container.

The image comes with a configuration file ([WebTunnelAgent.properties](WebTunnelAgent.properties)) that allows
configuring the most essential settings via environment variables.
The following environment variables are supported:

  - `WEBTUNNEL_DOMAIN`: The domain (UUID) of the device. Must be specified.
  - `WEBTUNNEL_DEVICE_ID`: The device ID to use. Must be specified.
  - `WEBTUNNEL_DEVICE_NAME`: The device name shown in the web user interface. Defaults to `Unnamed Device`.
  - `WEBTUNNEL_HOST`: The target host the agents forwards incoming tunneled connections to. Defaults to `172.17.0.1`, which
    is the IP address of the host from within a container in Docker's default *bridge* network.
  - `WEBTUNNEL_HTTP_PORT`: The port number of the device's web server. Defaults to 80. Set to 0 to disable HTTP access.
  - `WEBTUNNEL_HTTPS_ENABLE`: Set to `true` if device web server requires HTTPS instead of HTTP. Defaults to `false`.
  - `WEBTUNNEL_SSH_PORT`: The port number of the device's SSH server. Defaults to 0 (disabled).
  - `WEBTUNNEL_VNC_PORT`: The port number of the device's VNC server. Defaults to 0 (disabled).
  - `WEBTUNNEL_RDP_PORT`: The port number of the device's RDP server. Defaults to 0 (disabled).
  - `WEBTUNNEL_EXTRA_PORTS`: Additional port numbers (comma-separated) to be allowed. Defaults to empty.
  - `WEBTUNNEL_REFLECTOR_URI`: The address of the macchina.io REMOTE Server (*reflector*).
    Default: https://remote.macchina.io
  - `WEBTUNNEL_PASSWORD`: Optional device password. Defaults to none.
  - `WEBTUNNEL_CONNECT_TIMEOUT`: The timeout (in seconds) for connecting to the local (forwarded) server socket.
    Defaults to 10 seconds.
  - `WEBTUNNEL_LOCAL_TIMEOUT`: The timeout (in seconds) for local (forwarded) socket connections. Defaults to 7200 seconds or 2 hours.
  - `WEBTUNNEL_REMOTE_TIMEOUT`: The timeout (in seconds) for the WebTunnel connection to the macchina.io REMOTE server (*reflector*).
    Defaults to 300 seconds or 5 minutes.
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
for the container must be set up. In many cases, just using the default `bridge` network
created by Docker will work. For example, assuming that we want to access a web server
running on host port 8080, and also the host's SSH port:

```
$ docker run -e WEBTUNNEL_DOMAIN=eac8b99b-1866-4ef4-8f57-76b655949c29 -e WEBTUNNEL_DEVICE_ID=6e26e894-10a2-48bf-80f1-65a48527c80e -e WEBTUNNEL_HTTP_PORT=8080 -e WEBTUNNEL_SSH_PORT=22 macchina/device-agent
```

You must replace the values for `WEBTUNNEL_DOMAIN` and `WEBTUNNEL_DEVICE_ID` with your specific values.

Getting the network configuration right can be a bit tricky, as the *WebTunnelAgent* running in
the Docker container must be able to connect to network services provided by other containers,
the host running Docker, or other hosts in the network (depending on your needs).

The `WEBTUNNEL_HOST` environment variable must be set according to your Docker network configuration.
It defaults to `172.17.0.1`, which is the IP address of the host from within a container in Docker's
default *bridge* network. This will also work for accessing network ports that have been
exposed to the host by other containers. To access a service not exposed to the host by a container,
set `WEBTUNNEL_HOST` to the container's IP address and make sure the `macchina/device-agent`
container can reach the other container's network.

Please refer to the Docker documentation on [network containers](https://docs.docker.com/engine/tutorials/networkingcontainers/)
for more information.

## Running with Docker Compose

A sample [`docker-compose.yml`](docker-compose.yml) file and a sample environment file
([`sample.env`](sample.env)) are included in the repository. To launch with `docker-compose`,
update the environment file and run:

```
$ docker compose --env-file=sample.env up -d
```


## Configuration

The most important configuration settings can be set via environment variables (see above).
If you need to change other configuration options, edit [WebTunnelAgent.properties](WebTunnelAgent.properties)
and rebuild the Docker image.
For a description of all available configuration settings, see the
[WebTunnelAgent README](https://github.com/my-devices/sdk/blob/master/WebTunnel/WebTunnelAgent/README.md).
