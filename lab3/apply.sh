#!/usr/bin/env bash
set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
: "${STUDENT:?Выполни source lab.env}" "${N:?Выполни source lab.env}"
export N AS1=$((65000 + N)) AS2=$((65100 + N))
export VLAN_A=$((100 + N)) VLAN_B=$((200 + N))
export VNI_A=$((10000 + VLAN_A)) VNI_B=$((10000 + VLAN_B))
command -v envsubst >/dev/null

for leaf in leaf1 leaf2; do
  test -s "configs/${leaf}.sh"
  test -s "configs/${leaf}-frr.conf"
done

for leaf in leaf1 leaf2; do
  router_container="clab-${STUDENT}-l3-${leaf}"
  echo "== ${router_container}: ожидание портов"
  ready=0

  for attempt in {1..60}; do
    if docker exec "$router_container" bash -c 'test "$(redis-cli -n 4 exists "PORT|Ethernet0" "PORT|Ethernet4" "PORT|Ethernet8")" = 3 && ip link show Ethernet0 >/dev/null 2>&1 && ip link show Ethernet4 >/dev/null 2>&1 && ip link show Ethernet8 >/dev/null 2>&1' >/dev/null 2>&1; then
      ready=1
      break
    fi
    sleep 5
  done

  if [ "$ready" = 0 ]; then
    echo "Ошибка: ${router_container} не подготовил порты за 5 минут" >&2
    exit 1
  fi

  echo "== ${router_container}: интерфейсы и VXLAN"
  envsubst '${N} ${VLAN_A} ${VLAN_B} ${VNI_A} ${VNI_B}' < "configs/${leaf}.sh" | docker exec -i "$router_container" bash -se

  echo "== ${router_container}: FRR"
  envsubst '${N} ${AS1} ${AS2}' < "configs/${leaf}-frr.conf" | docker exec -i "$router_container" bash -ec 'cat > /tmp/lab3-frr.conf; vtysh -f /tmp/lab3-frr.conf; vtysh -c "write memory"'
done

echo "== Адреса хостов"
for host in host1 host2 host3 host4; do
  docker exec "clab-${STUDENT}-l3-${host}" ip link set eth1 mtu 1500
done
segment_b_octet=$((100 + N))
docker exec "clab-${STUDENT}-l3-host1" ip addr replace "192.168.${N}.11/24" dev eth1
docker exec "clab-${STUDENT}-l3-host2" ip addr replace "192.168.${N}.12/24" dev eth1
docker exec "clab-${STUDENT}-l3-host3" ip addr replace "192.168.${segment_b_octet}.13/24" dev eth1
docker exec "clab-${STUDENT}-l3-host4" ip addr replace "192.168.${segment_b_octet}.14/24" dev eth1

echo "Конфигурация применена. Подожди 20–30 секунд для установления BGP EVPN."
