# 2026-11-16 14:16:41 by RouterOS 7.23.8
# system id = DolDD9UDRVI
#
/interface ethernet set [ find default-name=ether1 ] disable-running-check=no
/interface ethernet set [ find default-name=ether2 ] disable-running-check=no
/interface ethernet set [ find default-name=ether3 ] disable-running-check=no
/interface wireguard add listen-port=13099 mtu=1420 name=wg-br
/interface list add comment=clab-mgmt name=clab-management
/interface list add comment=clab-mgmt exclude=clab-management include=static name=clab-discovery
/ip vrf add comment=clab-mgmt interfaces=ether1 name=mgmt
/routing bgp instance add as=65199 name=hq router-id=10.99.1.2
/ip neighbor discovery-settings set discover-interface-list=clab-discovery
/interface list member add comment=clab-mgmt interface=ether1 list=clab-management
/interface wireguard peers add allowed-address=10.99.254.2/32,10.99.200.0/24 endpoint-address=100.64.2.2 endpoint-port=13099 interface=wg-br name=peer1 persistent-keepalive=25s public-key="WmiOoOwIaqxlVNjO08zGIr0f3HNiTk8jAVpdwKNLUBM="
/ip address add address=10.105.99.11/24 comment=clab-mgmt interface=ether1 network=10.105.99.0
/ip address add address=10.99.1.2/30 comment="to DC" interface=ether2 network=10.99.1.0
/ip address add address=100.64.1.2/30 comment=WAN interface=ether3 network=100.64.1.0
/ip address add address=10.99.254.1/30 interface=wg-br network=10.99.254.0
/ip dhcp-client add disabled=yes interface=ether1 name=client1
/ip firewall address-list add address=10.99.200.0/24 list=to-dc
/ip firewall filter add action=accept chain=input comment="input established" connection-state=established,related
/ip firewall filter add action=drop chain=input comment="input invalid" connection-state=invalid
/ip firewall filter add action=accept chain=input comment="input ICMP" protocol=icmp
/ip firewall filter add action=accept chain=input comment=management in-interface=mgmt
/ip firewall filter add action=accept chain=input comment="BGP from DC" dst-port=179 in-interface=ether2 protocol=tcp
/ip firewall filter add action=accept chain=input comment=WireGuard dst-port=13099 in-interface=ether3 protocol=udp
/ip firewall filter add action=drop chain=input comment="drop other from WAN" in-interface=ether3
/ip firewall filter add action=drop chain=input comment="input default deny"
/ip firewall filter add action=accept chain=forward comment="forward established" connection-state=established,related
/ip firewall filter add action=drop chain=forward comment="forward invalid" connection-state=invalid
/ip firewall filter add action=accept chain=forward comment="DC to Internet" in-interface=ether2 out-interface=ether3
/ip firewall filter add action=accept chain=forward comment="branch to DC" in-interface=wg-br out-interface=ether2
/ip firewall filter add action=accept chain=forward comment="DC to branch" in-interface=ether2 out-interface=wg-br
/ip firewall filter add action=drop chain=forward comment="default deny"
/ip firewall nat add action=masquerade chain=srcnat comment="DC to Internet" out-interface=ether3
/ip route add comment=clab-mgmt dst-address=0.0.0.0/0 gateway=10.105.99.1@mgmt routing-table=mgmt
/ip route add comment=ISP dst-address=0.0.0.0/0 gateway=100.64.1.1
/ip route add comment="branch via WireGuard" dst-address=10.99.200.0/24 gateway=wg-br
/ip service set ssh vrf=mgmt
/ip service set telnet vrf=mgmt
/ip service set www vrf=mgmt
/ip service set www-ssl vrf=mgmt
/ip service set winbox vrf=mgmt
/ip service set api vrf=mgmt
/ip service set api-ssl vrf=mgmt
/ipv6 nd add interface=ether1 ra-lifetime=none
/routing bgp connection add instance=hq local.address=10.99.1.2 .role=ebgp name=to-dc output.default-originate=if-installed .network=to-dc remote.address=10.99.1.1 .as=65099
/snmp set vrf=mgmt
/system identity set name=hq-makarov
