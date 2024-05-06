#!/bin/bash

# parámetros
NombreVM="$1"
NombreOvS="$2"
VLAN_ID="$3"
PuertoVNC="$4"


puertoVNC_local = "$((PuertoVNC - 5900))"

# crear interfaz TAP
interfaz_tap_vm = "$NombreOvS"-"$NombreVM"-tap
ip tuntap add mode tap name "$interfaz_tap_vm"

# crear VM (script lab2)
qemu-system-x86_64 \
-enable-kvm \
-vnc 0.0.0.0:"$puertoVNC_local"\
-netdev tap,id="$interfaz_tap_vm",ifname="$interfaz_tap_vm",script=no,downscript=no \
-device e1000,netdev="$interfaz_tap_vm",mac=20:20:03:34:ee:0"$puertoVNC_local" \   # variar los dos ultimos
-daemonize \
-snapshot \
cirros-0.5.1-x86_64-disk.img

# Conectar interfaz TAP al OvS del host local con el VLAN ID correspondiente
ovs-vsctl add-port "$NombreOvS" "$interfaz_tap_vm" tag="$VLAN_ID"
ip link set "$interfaz_tap_vm" up

# Mostrar información
echo "VM $NombreVM creada y conectada al OvS $NombreOvS con VLAN ID $VLAN_ID."
