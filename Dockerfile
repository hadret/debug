FROM debian:sid
LABEL org.opencontainers.image.source https://github.com/hadret/debug
LABEL org.opencontainers.image.licenses=MIT

RUN apt-get update -qq && \
    apt-get install --no-install-recommends --yes \
                      apache2-utils \
                      atop \
                      bind9-dnsutils \
                      bird \
                      bpfcc-tools \
                      bpftool \
                      bpftrace \
                      bridge-utils \
                      busybox \
                      ca-certificates \
                      conntrack \
                      coreutils \
                      curl \
                      dhcping \
                      dstat \
                      ethtool \
                      file \
                      fping \
                      gnupg \
                      htop \
                      httpie \
                      httping \
                      iftop\
                      iperf3 \
                      iproute2 \
                      ipset \
                      iptables \
                      iptraf-ng \
                      iputils-ping \
                      ipvsadm \
                      jq \
                      less \
                      man \
                      moreutils \
                      mtr-tiny \
                      ncat \
                      net-tools \
                      netcat-openbsd \
                      nftables \
                      ngrep \
                      nmap \
                      openssh-client \
                      openssl \
                      procps \
                      psmisc \
                      python3-scapy \
                      socat \
                      strace \
                      tcpdump \
                      tcptraceroute \
                      tmux \
                      tshark \
                      vim \
                      wget && \
    rm -Rf /var/lib/apt/lists/*  && \
    apt-get clean

CMD [ "/bin/bash" ]
