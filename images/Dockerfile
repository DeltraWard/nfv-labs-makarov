FROM debian:trixie-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
      openvswitch-switch iproute2 iputils-ping tcpdump procps ethtool \
    && rm -rf /var/lib/apt/lists/*
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
