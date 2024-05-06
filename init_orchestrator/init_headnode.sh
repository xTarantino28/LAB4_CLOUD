#!/bin/bash

# parametros
nombreOvS="$1"
InterfacesAConectar="$2"

# crear ovs local en headnode 
ovs-vsctl br-exists "$nombreOvS" || ovs-vsctl add-br "$nombreOvS"

# conectar lista de interfaces del headnode al ovs (de los 3 namespaces y las 3 interfaces VLAN)
for iface in $InterfacesAConectar; do
    ovs-vsctl add-port "$nombreOvS" "$iface"
done

ip link set dev "$nombreOvS" up

# activar IPv4 Forwarding
sysctl -w net.ipv4.ip_forward=1

# cambiar default action del chain FORWARD a DROP
iptables -P FORWARD DROP #esta regla me quita internet de los workers cuidado

# mensaje de confirmacion e inicializacion
echo "HeadNode inicializado correctamente."
