#!/usr/bin/env bash
set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
: "${STUDENT:?Выполни source lab.env}" "${N:?Выполни source lab.env}"
export N AS1=$((65000 + N)) AS2=$((65100 + N))
command -v envsubst >/dev/null

for router in r1 r2; do
  test -s "configs/${router}.sh"
  test -s "configs/${router}-frr.conf"
done

for router in r1 r2; do
  router_container="clab-${STUDENT}-l2-${router}"
  echo "== ${router_container}: ожидание портов"
  ready=0

  for attempt in {1..60}; do
    if docker exec "$router_container" bash -c 'test "$(redis-cli -n 4 exists "PORT|Ethernet0")" = 1 && ip link show Ethernet0 >/dev/null 2>&1 && ip link show Ethernet4 >/dev/null 2>&1' >/dev/null 2>&1; then
      ready=1
      break
    fi
    sleep 5
  done

  if [ "$ready" = 0 ]; then
    echo "Ошибка: ${router_container} не подготовил порты за 5 минут" >&2
    exit 1
  fi

  echo "== ${router_container}: интерфейсы"
  envsubst '${N}' < "configs/${router}.sh" | docker exec -i "$router_container" bash -se

  echo "== ${router_container}: FRR"
  envsubst '${N} ${AS1} ${AS2}' < "configs/${router}-frr.conf" | docker exec -i "$router_container" bash -ec 'cat > /tmp/lab2-frr.conf; vtysh -f /tmp/lab2-frr.conf; vtysh -c "write memory"'
done

echo "Конфигурация применена. Подожди 20–30 секунд для установления BGP."
