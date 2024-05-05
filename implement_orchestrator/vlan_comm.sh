#!/bin/bash

# pParámetros
VLAN_SUBNET_1="$1"  # Subred de la VLAN 1
VLAN_SUBNET_2="$2"  # Subred de la VLAN 2

# habilitar el enrutamiento IPv4
echo 1 > /proc/sys/net/ipv4/ip_forward

# permitir el tráfico entre las dos subredes VLAN
iptables -A FORWARD -i br-int -o br-int -s $VLAN_SUBNET_1 -d $VLAN_SUBNET_2 -j ACCEPT
iptables -A FORWARD -i br-int -o br-int -s $VLAN_SUBNET_2 -d $VLAN_SUBNET_1 -j ACCEPT

# asegurarse de que el tráfico de retorno también esté permitido
iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

echo "Comunicación entre VLANs $VLAN_SUBNET_1 y $VLAN_SUBNET_2 permitida."
