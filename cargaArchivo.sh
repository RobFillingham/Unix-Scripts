#!/bin/bash

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

# Importa la biblioteca ncurses
if ! type "dialog" >/dev/null 2>&1; then
  echo "El programa 'dialog' no está instalado. Por favor, instálalo para utilizar la interfaz ncurses."
  exit 1
fi

# Lee cada línea del archivo y muestra un formulario para cada usuario
while IFS=: read -r nombre_usuario contrasena_usuario
do
  # Verifica si el usuario ya existe
  if id "$nombre_usuario" &>/dev/null; then
    dialog --infobox "El usuario $nombre_usuario ya existe. Se omitirá." 0 0
    sleep 2
  else
    # Muestra el formulario para crear el usuario
    form=$(dialog --stdout --title "Crear Usuario" --form "Ingrese los datos para el usuario $nombre_usuario:" 0 0 0 \
      "Nombre de usuario:" 1 1 "$nombre_usuario" 1 25 30 0 \
      "Contraseña:" 2 1 "$contrasena_usuario" 2 25 30 0)
  
    # Extrae los valores del formulario
    nombre_usuario=$(echo "$form" | awk 'NR==1{print $NF}')
    contrasena_usuario=$(echo "$form" | awk 'NR==2{print $NF}')
  
    # Crea el usuario utilizando el comando useradd
    useradd -m -p "$(openssl passwd -1 "$contrasena_usuario")" "$nombre_usuario"
    dialog --infobox "El usuario $nombre_usuario se ha creado exitosamente." 0 0
    sleep 2
  fi
done < "$archivo_usuarios"

