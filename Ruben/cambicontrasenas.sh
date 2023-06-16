#!/bin/bash

# Importa la biblioteca ncurses
if ! type "dialog" >/dev/null 2>&1; then
  echo "El programa 'dialog' no está instalado. Por favor, instálalo para utilizar la interfaz ncurses."
  exit 1
fi

# Verifica si se proporcionó el archivo de texto como argumento
if [ $# -eq 0 ]; then
  echo "Uso: $0 archivo_usuarios.txt"
  exit 1
fi

archivo_usuarios=$1

# Verifica si el archivo de usuarios existe
if [ ! -f "$archivo_usuarios" ]; then
  echo "El archivo $archivo_usuarios no existe."
  exit 1
fi

# Lee cada línea del archivo y cambia la contraseña de cada usuario
while IFS=: read -r nombre_usuario contrasena_nueva
do
  # Verifica si el usuario existe
  if id "$nombre_usuario" &>/dev/null; then
    # Crea la interfaz de usuario para cambiar la contraseña
    form=$(dialog --stdout --title "Cambio de Contraseña" --form "Ingrese la nueva contraseña para el usuario $nombre_usuario:" 0 0 0 \
      "Nueva Contraseña:" 1 1 "" 1 25 30 0 \
      "Confirmar Contraseña:" 2 1 "" 2 25 30 0)

    # Extrae la nueva contraseña del formulario
    contrasena_nueva=$(echo "$form" | awk 'NR==1{print $NF}')
    confirmar_contrasena=$(echo "$form" | awk 'NR==2{print $NF}')

    # Verifica que la contraseña y la confirmación coincidan
    if [ "$contrasena_nueva" == "$confirmar_contrasena" ]; then
      # Cambia la contraseña utilizando el comando passwd
      echo -e "$contrasena_nueva\n$contrasena_nueva" | passwd "$nombre_usuario"
      dialog --infobox "Se ha cambiado la contraseña del usuario $nombre_usuario." 0 0
      sleep 2
    else
      dialog --msgbox "Las contraseñas no coinciden para el usuario $nombre_usuario. No se cambió la contraseña." 0 0
    fi
  else
    dialog --msgbox "El usuario $nombre_usuario no existe. No se cambió la contraseña." 0 0
  fi
done < "$archivo_usuarios"
