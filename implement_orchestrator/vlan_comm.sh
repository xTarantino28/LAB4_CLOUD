#!/bin/bash

# pParámetros
VLAN_ID_1="$1"  # Subred de la VLAN 1
VLAN_ID_2="$2"  # Subred de la VLAN 2

# habilitar el enrutamiento IPv4
echo 1 > /proc/sys/net/ipv4/ip_forward

# para vlan_id_1
# Obtener el nombre de la interfaz asociada con la VLAN
interface_name=$(sudo ovs-vsctl list port | grep "$VLAN_ID_1" | awk '{print $3}' | head -n 1)
# Obtener la información de la dirección IP y la máscara de subred de la interfaz
interface_info=$(ip addr show dev $interface_name)
if [ -z "$interface_info" ]; then
    echo "No se encontró ninguna interfaz con VLAN ID $VLAN_ID_1"
    exit 1
fi
# Extraer la dirección de red y la máscara de subred de la salida
ip_address=$(echo "$interface_info" | awk '/inet / {split($2, ip_parts, "/"); print ip_parts[1]}')
# Extraer la dirección IP y la máscara de subred de la salida
subnet_mask=$(echo "$interface_info" | awk '/inet / {print $2}' | awk -F/ '{print $2}')
# Calcular la dirección de red a partir de la dirección IP y la máscara de subred
vlan_cidr_1=$(ipcalc -n $ip_address/$subnet_mask | awk '/Network/ {print $2}') # extrae la direcc de red peroo con formato cidr



# para vlan_id_1
# Obtener el nombre de la interfaz asociada con la VLAN
interface_name=$(sudo ovs-vsctl list port | grep "$VLAN_ID_2" | awk '{print $3}' | head -n 1)
# Obtener la información de la dirección IP y la máscara de subred de la interfaz
interface_info=$(ip addr show dev $interface_name)
if [ -z "$interface_info" ]; then
    echo "No se encontró ninguna interfaz con VLAN ID $VLAN_ID_2"
    exit 1
fi
# Extraer la dirección de red y la máscara de subred de la salida
ip_address=$(echo "$interface_info" | awk '/inet / {split($2, ip_parts, "/"); print ip_parts[1]}')
# Extraer la dirección IP y la máscara de subred de la salida
subnet_mask=$(echo "$interface_info" | awk '/inet / {print $2}' | awk -F/ '{print $2}')
# Calcular la dirección de red a partir de la dirección IP y la máscara de subred
vlan_cidr_2=$(ipcalc -n $ip_address/$subnet_mask | awk '/Network/ {print $2}') # extrae la direcc de red peroo con formato cidr


# permitir el tráfico entre las dos subredes VLAN
iptables -A FORWARD -i br-int -o br-int -s $vlan_cidr_1 -d $vlan_cidr_2 -j ACCEPT
iptables -A FORWARD -i br-int -o br-int -s $vlan_cidr_2 -d $vlan_cidr_1 -j ACCEPT

# asegurarse de que el tráfico de retorno también esté permitido
iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

echo "Comunicación entre VLANs $vlan_cidr_1 y $vlan_cidr_2 permitida."
