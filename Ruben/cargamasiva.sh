#!/bin/bash

# Importa la biblioteca ncurses
if ! type "dialog" >/dev/null 2>&1; then
  echo "El programa 'dialog' no está instalado. Por favor, instálalo para utilizar la interfaz ncurses."
  exit 1
fi

# Solicita la cantidad de usuarios a crear
cantidad_usuarios=$(dialog --stdout --inputbox "Ingrese la cantidad de usuarios que desea crear:" 0 0)
if [ -z "$cantidad_usuarios" ]; then
  echo "No se proporcionó la cantidad de usuarios."
  exit 1
fi

# Crea la interfaz de usuario para ingresar los datos de cada usuario
usuarios=()
for ((i=1; i<=$cantidad_usuarios; i++))
do
  form=$(dialog --stdout --title "Crear Usuario $i" --form "Ingrese los datos para el usuario $i:" 0 0 0 \
    "Nombre de usuario:" 1 1 "" 1 25 30 0 \
    "Contraseña:" 2 1 "" 2 25 30 0)
  
  # Extrae los valores del formulario
  nombre_usuario=$(echo "$form" | awk 'NR==1{print $NF}')
  contrasena_usuario=$(echo "$form" | awk 'NR==2{print $NF}')
  
  # Agrega el usuario a la lista
  usuarios+=("$nombre_usuario:$contrasena_usuario")
done

# Crea los usuarios utilizando el comando useradd
for usuario in "${usuarios[@]}"
do
  nombre_usuario=$(echo "$usuario" | cut -d ":" -f 1)
  contrasena_usuario=$(echo "$usuario" | cut -d ":" -f 2)
  
  # Verifica si el usuario ya existe
  if id "$nombre_usuario" &>/dev/null; then
    dialog --infobox "El usuario $nombre_usuario ya existe. Se omitirá." 0 0
    sleep 2
  else
    # Crea el usuario utilizando el comando useradd
    useradd -m -p "$(openssl passwd -1 "$contrasena_usuario")" "$nombre_usuario"
    dialog --infobox "El usuario $nombre_usuario se ha creado exitosamente." 0 0
    sleep 2
  fi
done
