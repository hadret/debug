# Debug Docker image

[![build](https://github.com/hadret/debug/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/hadret/debug/actions/workflows/build.yml)

I created this image as any other I tried was lacking some of the features or
applications I wanted/needed. I'm basing it off of Debian Sid (unstable) to
ensure relatively new packages of, well, _everything_. There are no releases nor
tags -- instead this image will always provide `latest` and will auto-update
every week.

The main reason this image is relatively big (1.22 GB for `arm64` and 856 MB for
`amd64`) is because I didn't want to strip manpages -- they are a must for me.

## How to use with Docker?

Start a container you wanna debug using this image, in my case I went with my
own tiny go app (this assumes you don't have a container you wanna debug
already running, of course):

```shell
docker run -d --name forwardly -p 8000:8000 ghcr.io/hadret/forwardly-go:latest
```

Now's the time for magic attachement:

```shell
# Grab the ID of the container you wanna attach to
docker ps

31d5d7b218f0   ghcr.io/hadret/forwardly-go:latest   "/forwardly-go"   3 minutes ago   Up 3 minutes   0.0.0.0:8000->8000/tcp   forwardly

# Attach all the things
docker run -it --privileged --net=container:31d5d7b218f0 --pid=container:31d5d7b218f0 ghcr.io/hadret/debug:latest
```

Once that's done, you now have access to all the processes and also network
sockets:

```shell
root@31d5d7b218f0:~# ps fauxww
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root        12  0.0  0.0   4024  3220 pts/0    Ss   14:47   0:00 /bin/bash
root        19  0.0  0.0   8104  3532 pts/0    R+   14:48   0:00  \_ ps fauxww
65532        1  0.0  0.1 1088568 10572 ?       Ssl  14:43   0:00 /forwardly-go

root@31d5d7b218f0:~# strace -p 1
strace: Process 1 attached
epoll_pwait(4, [{events=EPOLLIN, data={u32=2149536152, u64=281472831279512}}], 128, -1, NULL, 0) = 1
futex(0x89c220, FUTEX_WAKE_PRIVATE, 1)  = 1
futex(0x89c138, FUTEX_WAKE_PRIVATE, 1)  = 1
accept4(3, {sa_family=AF_INET6, sin6_port=htons(53614), sin6_flowinfo=htonl(0), inet_pton(AF_INET6, "::ffff:172.17.0.1", &sin6_addr), sin6_scope_id=0}, [112 => 28], SOCK_CLOEXEC|SOCK_NONBLOCK) = 7
epoll_ctl(4, EPOLL_CTL_ADD, 7, {events=EPOLLIN|EPOLLOUT|EPOLLRDHUP|EPOLLET, data={u32=2149535912, u64=281472831279272}}) = 0
getsockname(7, {sa_family=AF_INET6, sin6_port=htons(8000), sin6_flowinfo=htonl(0), inet_pton(AF_INET6, "::ffff:172.17.0.2", &sin6_addr), sin6_scope_id=0}, [112 => 28]) = 0
[...]

root@31d5d7b218f0:~# lsof -w -i :8000
COMMAND   PID     USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
forwardly   1    65532    3u  IPv6  54201      0t0  TCP *:8000 (LISTEN)
```

There are different ways to connect -- if running container in privileged mode
is not an option, there's always possibility to add specific capabilities
instead (depending on what's needed, for example for `strace` probably
`--cap-add` for `sys_admin` and `sys_ptrace` would be necessary). If network is
of no interest the `--net` part can be omitted completely. If not tracing is
necessary, then the attached command can be simplified even further:

```
docker run -it --pid=container:31d5d7b218f0 --cap-add sys_admin ghcr.io/hadret/debug:latest
```

More example can be found in this great write-up:
[How-to Debug a Running Docker Container from a Separate Container](https://rothgar.medium.com/how-to-debug-a-running-docker-container-from-a-separate-container-983f11740dc6).

## How to use with Kubernetes?
