#!/bin/bash

# Importa la biblioteca ncurses
if ! type "dialog" >/dev/null 2>&1; then
  echo "El programa 'dialog' no está instalado. Por favor, instálalo para utilizar la interfaz ncurses."
  exit 1
fi

# Solicita la cantidad de usuarios a cambiar la contraseña
cantidad_usuarios=$(dialog --stdout --inputbox "Ingrese la cantidad de usuarios a cambiar la contraseña:" 0 0)
if [ -z "$cantidad_usuarios" ]; then
  echo "No se proporcionó la cantidad de usuarios."
  exit 1
fi

# Crea la interfaz de usuario para ingresar los datos de cada usuario
usuarios=()
for ((i=1; i<=$cantidad_usuarios; i++))
do
  form=$(dialog --stdout --title "Cambio de Contraseña" --form "Ingrese los datos para el usuario $i:" 0 0 0 \
    "Nombre de usuario:" 1 1 "" 1 25 30 0 \
    "Nueva contraseña:" 2 1 "" 2 25 30 0 \
    "Confirmar contraseña:" 3 1 "" 3 25 30 0)
  
  # Extrae los valores del formulario
  nombre_usuario=$(echo "$form" | awk 'NR==1{print $NF}')
  contrasena_nueva=$(echo "$form" | awk 'NR==2{print $NF}')
  confirmar_contrasena=$(echo "$form" | awk 'NR==3{print $NF}')
  
  # Verifica que la contraseña y la confirmación coincidan
  if [ "$contrasena_nueva" == "$confirmar_contrasena" ]; then
    # Agrega el usuario a la lista
    usuarios+=("$nombre_usuario:$contrasena_nueva")
  else
    dialog --msgbox "Las contraseñas no coinciden para el usuario $nombre_usuario. No se cambió la contraseña." 0 0
  fi
done

# Cambia las contraseñas utilizando el comando passwd
for usuario in "${usuarios[@]}"
do
  nombre_usuario=$(echo "$usuario" | cut -d ":" -f 1)
  contrasena_nueva=$(echo "$usuario" | cut -d ":" -f 2)
  
  # Verifica si el usuario existe
  if id "$nombre_usuario" &>/dev/null; then
    # Cambia la contraseña utilizando el comando passwd
    echo -e "$contrasena_nueva\n$contrasena_nueva" | passwd "$nombre_usuario"
    dialog --infobox "Se ha cambiado la contraseña del usuario $nombre_usuario." 0 0
    sleep 2
  else
    dialog --msgbox "El usuario $nombre_usuario no existe. No se cambió la contraseña." 0 0
  fi
done
