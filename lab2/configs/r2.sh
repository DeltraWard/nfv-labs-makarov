#!/usr/bin/env bash
set -euo pipefail

for service in zebra mgmtd staticd bgpd; do
  if ! supervisorctl status "$service" | grep -q RUNNING; then
    supervisorctl start "$service"
  fi
done

sudo config interface startup Ethernet0
sudo config interface startup Ethernet4

if [ "$(redis-cli -n 4 exists 'LOOPBACK_INTERFACE|Loopback0')" = 0 ]; then
  sudo config loopback add Loopback0
fi

if [ "$(redis-cli -n 4 exists "INTERFACE|Ethernet0|10.${N}.2.1/24")" = 0 ]; then
  sudo config interface ip add Ethernet0 10.${N}.2.1/24
fi

if [ "$(redis-cli -n 4 exists "INTERFACE|Ethernet4|10.${N}.0.1/31")" = 0 ]; then
  sudo config interface ip add Ethernet4 10.${N}.0.1/31
fi

if [ "$(redis-cli -n 4 exists "LOOPBACK_INTERFACE|Loopback0|10.${N}.255.2/32")" = 0 ]; then
  sudo config interface ip add Loopback0 10.${N}.255.2/32
fi

sudo config save -y
