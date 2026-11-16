odl_get() {
  curl --noproxy '*' -fsS --connect-timeout 5 --max-time 30 -u admin:admin -H 'Accept: application/yang-data+json' "$ODL/rests/data/$1" | jq .
}
