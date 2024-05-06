#!/bin/bash

# parámetros
nombreOvS="$1"
InterfacesAConectar="$2"

# crear ovs local al worker# si no existe
ovs-vsctl br-exists "$nombreOvS" || ovs-vsctl add-br "$nombreOvS"

# conectar lista de interfaces al ovs (ens4 salida del worker hacia OFS y 
# deben crearse tantas interfaces TAP para vincularse con las tantas VMs a crear en el worker) 
for iface in $InterfacesAConectar; do
    ovs-vsctl add-port "$nombreOvS" "$iface"
done

ip link set dev "$nombreOvS" up

# mostrar confirmacion de inicializacion
echo "Worker inicializado correctamente."
