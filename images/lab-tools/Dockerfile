# Универсальный образ для хостов и VNF: iproute2, nftables, tc, iperf3, tcpdump, curl, python3
FROM alpine:3.22
RUN apk add --no-cache bash curl iperf3 tcpdump nftables iproute2 iproute2-tc iputils-ping \
      conntrack-tools ethtool python3 jq
CMD ["sleep", "infinity"]
