# Asignar argumentos a variables
direccion_red_cidr="$1"

# Extraer la dirección de red y la máscara de subred
direccion_red=$(echo $direccion_red_cidr | cut -d '/' -f1)
mascara_subred=$(echo $direccion_red_cidr | cut -d '/' -f2)

# Calcular la primera dirección disponible
IFS='.' read -r -a octetos <<< "$direccion_red"
octetos[3]=$(( ${octetos[3]} + 1 ))
primera_direccion_disponible="${octetos[0]}.${octetos[1]}.${octetos[2]}.${octetos[3]}"

# Calcular la segunda dirección disponible sumando 1 a la primera dirección disponible
IFS='.' read -r -a octetos_segunda <<< "$primera_direccion_disponible"
octetos_segunda[3]=$(( ${octetos_segunda[3]} + 1 ))
segunda_direccion_disponible="${octetos_segunda[0]}.${octetos_segunda[1]}.${octetos_segunda[2]}.${octetos_segunda[3]}"

echo "La primera dirección disponible es: $primera_direccion_disponible"
echo "La segunda dirección disponible es: $segunda_direccion_disponible"