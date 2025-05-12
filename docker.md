# memo

## Run podman inside Docker container

Docker limits permissions when building/running containers.\
To use Podman in a Docker container, security mitigations should be disabled.

## Docker-in-Docker Official image

Official Docker in Docker image based on apline.\
It is hard to use unless just use docker command.\
The Official Docker-in-Docker image is based on Alpine Linux.\
It can be difficult to use unless you simply use the Docker command.

```shell
docker run --privileged hoge
#or
docker run --security-opt seccomp=unconfined hoge
```

## Proxy Settings in Docker

When the proxy settings were defined in `~/.docker/config`,\
The Docker automatically exports the these settings to the container. \
To prevent this, the 'no_proxy' environment variable should be set when building container.
