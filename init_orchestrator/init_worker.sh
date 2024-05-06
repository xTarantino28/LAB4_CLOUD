#!/bin/bash

# parámetros
nombreDeOvS="$1"
InterfacesAConectar="$2"

# crear ovs local al worker# si no existe
ovs-vsctl br-exists "$nombreDeOvS" || ovs-vsctl add-br "$nombreDeOvS"

# conectar lista de interfaces al ovs (ens4 salida del worker hacia OFS y 
# deben crearse tantas interfaces TAP para vincularse con las tantas VMs a crear en el worker) 
for iface in $InterfacesAConectar; do
    ovs-vsctl add-port "$nombreDeOvS" "$iface"
done

ip link set dev "$nombreDeOvS" up

# mostrar confirmacion de inicializacion
echo "Worker inicializado correctamente."
