#!/usr/bin/env bash
set -euo pipefail

leaf_id=2
underlay_address="10.${N}.0.$((leaf_id - 1))/31"
loopback_address="10.${N}.255.${leaf_id}/32"

for service in zebra mgmtd staticd bgpd vxlanmgrd; do
  if ! supervisorctl status "$service" | grep -q RUNNING; then
    supervisorctl start "$service"
  fi
done

for port in Ethernet0 Ethernet4 Ethernet8; do
  sudo config interface startup "$port"
done

if [ "$(redis-cli -n 4 exists 'LOOPBACK_INTERFACE|Loopback0')" = 0 ]; then
  sudo config loopback add Loopback0
fi

if [ "$(redis-cli -n 4 exists "INTERFACE|Ethernet4|${underlay_address}")" = 0 ]; then
  sudo config interface ip add Ethernet4 "$underlay_address"
fi

if [ "$(redis-cli -n 4 exists "LOOPBACK_INTERFACE|Loopback0|${loopback_address}")" = 0 ]; then
  sudo config interface ip add Loopback0 "$loopback_address"
fi

if [ "$(redis-cli -n 4 exists 'VXLAN_TUNNEL|vtep')" = 0 ]; then
  sudo config vxlan add vtep "${loopback_address%/*}"
fi

if [ "$(redis-cli -n 4 exists 'VXLAN_EVPN_NVO|nvo')" = 0 ]; then
  sudo config vxlan evpn_nvo add nvo vtep
fi

for binding in "${VLAN_A}:Ethernet0:${VNI_A}" "${VLAN_B}:Ethernet8:${VNI_B}"; do
  IFS=: read -r vlan port vni <<< "$binding"

  if [ "$(redis-cli -n 4 exists "VLAN|Vlan${vlan}")" = 0 ]; then
    sudo config vlan add "$vlan"
  fi

  if [ "$(redis-cli -n 4 exists "VLAN_MEMBER|Vlan${vlan}|${port}")" = 0 ]; then
    sudo config vlan member add -u "$vlan" "$port"
  fi

  if [ "$(redis-cli -n 4 exists "VXLAN_TUNNEL_MAP|vtep|map_${vni}_Vlan${vlan}")" = 0 ]; then
    sudo config vxlan map add vtep "$vlan" "$vni"
  fi
done

sudo config save -y
