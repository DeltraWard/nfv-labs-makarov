#!/usr/bin/env bash
set -euo pipefail
task_root=$(cd -- "$(dirname -- "$0")" && pwd)
download_dir="$task_root/downloads"
mkdir -p "$download_dir"
command -v docker >/dev/null
command -v curl >/dev/null
docker build -t lab-tools:1.0 "$task_root/images/lab-tools"
if ! docker image inspect docker-sonic-vs:202511 >/dev/null 2>&1; then
    artifact_url='https://sonic-build.azurewebsites.net/api/sonic/artifacts'
    curl -fL --retry 3 --get "$artifact_url" \
        --data-urlencode 'branchName=202511' \
        --data-urlencode 'platform=vs' \
        --data-urlencode 'buildId=1268989' \
        --data-urlencode 'target=target/docker-sonic-vs.gz' \
        -o "$download_dir/docker-sonic-vs-202511.gz"
    docker load -i "$download_dir/docker-sonic-vs-202511.gz"
    docker tag docker-sonic-vs:latest docker-sonic-vs:202511
fi
docker build -t sonic-course:202511 "$task_root/images/sonic-course"
docker images --format '{{.Repository}}:{{.Tag}} {{.ID}} {{.Size}}'
docker run --rm --entrypoint /bin/cat \
    sonic-course:202511 /etc/sonic/sonic_version.yml
