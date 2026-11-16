#!/bin/sh
# Запуск OVS в userspace-режиме (datapath netdev): модуль ядра openvswitch на хосте не нужен
set -e
mkdir -p /var/run/openvswitch /etc/openvswitch
[ -f /etc/openvswitch/conf.db ] || ovsdb-tool create /etc/openvswitch/conf.db /usr/share/openvswitch/vswitch.ovsschema
ovsdb-server --remote=punix:/var/run/openvswitch/db.sock --pidfile --detach --log-file
ovs-vsctl --no-wait init
ovs-vswitchd --pidfile --detach --log-file
exec sleep infinity
