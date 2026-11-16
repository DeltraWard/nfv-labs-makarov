#!/usr/bin/env bash
set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."
source lab.env

response=$(mktemp)
trap 'rm -f "$response"' EXIT

for name in s1-1to2 s1-2to1 s2-to-h2-ip s2-to-h2-arp s2-to-h3-ip s2-to-h3-arp s2-1to2 s2-3to2; do
  switch=${name:1:1}
  flow_id="${STUDENT}-${name}"
  file="flows/${name}.json"
  url="${ODL}/rests/data/opendaylight-inventory:nodes/node=openflow%3A${switch}/flow-node-inventory:table=0/flow=${flow_id}"

  test -s "$file"
  status=$(curl --noproxy '*' -sS -u admin:admin -X PUT -H 'Content-Type: application/json' --data-binary "@${file}" -o "$response" -w '%{http_code}' "$url")

  echo "PUT ${flow_id}: HTTP ${status}"

  if [[ "$status" != 201 && "$status" != 204 ]]; then
    cat "$response"
    exit 1
  fi
done
