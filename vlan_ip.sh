#!/bin/bash

VLAN_ID="$1"

# Obtener el nombre de la interfaz asociada con la VLAN
interface_name=$(sudo ovs-vsctl list port | grep "$VLAN_ID" | awk '{print $3}' | head -n 1)

# Obtener la información de la dirección IP y la máscara de subred de la interfaz
interface_info=$(ip addr show dev $interface_name)
if [ -z "$interface_info" ]; then
    echo "No se encontró ninguna interfaz con VLAN ID $VLAN_ID"
    exit 1
fi

echo "interface info : $interface_info"
# Extraer la dirección de red y la máscara de subred de la salida
# ip_address=$(echo "$interface_info" | awk '/inet / {print $2}') # extrae todo en formato cidr


ip_address=$(echo "$interface_info" | awk '/inet / {split($2, ip_parts, "/"); print ip_parts[1]}')

# Extraer la dirección IP y la máscara de subred de la salida
subnet_mask=$(echo "$interface_info" | awk '/inet / {print $2}' | awk -F/ '{print $2}')

# Calcular la dirección de red a partir de la dirección IP y la máscara de subred
# ip_network=$(ipcalc -n $ip_address/$subnet_mask | awk '/Network/ {print $2}') # extrae la direcc de red peroo con formato cidr

ip_network=$(ipcalc -n $ip_address/$subnet_mask | awk '/Network/ {split($2, parts, "/"); print parts[1]}')


# Imprimir la dirección de red en formato CIDR
echo "Dirección de red asociada a la VLAN ID $VLAN_ID (formato CIDR): $ip_network/$subnet_mask"