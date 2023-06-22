#!/bin/bash

respuesta="aaa.txt"

# Función para mostrar la opción seleccionada
mostrar_opcion() {
  dialog --infobox "$1" 0 0
  sleep 2
}

# Función para el código de la opción 1 (ALTA MASIVA DE USUARIOS)
opcion_1() {
  # Verifica si el archivo de usuarios existe
  if [ ! -f "usuarios.txt" ]; then
    dialog --msgbox "El archivo usuarios.txt no existe en el directorio actual." 0 0
    return
  fi

  # Lee el archivo de usuarios y crea los usuarios
  dialog --passwordbox "Ingresa la contraseña de sudo:" 8 40 --insecure 2> $respuesta
	password=$(head -n1 "$respuesta")
  while IFS=: read -r nombre_usuario contrasena_usuario
  do
    # Verifica si el usuario ya existe
    if id "$nombre_usuario" &>/dev/null; then
      dialog --infobox "El usuario $nombre_usuario ya existe. Se omitirá." 0 0
      sleep 2
    else
      # Crea el usuario utilizando el comando useradd
      #dialog --passwordbox "Ingresa la contraseña de sudo:" 8 40 --insecure 2> $respuesta
	#password=$(head -n1 "$respuesta")
      echo "$password" | sudo useradd -m -p "$(openssl passwd -1 "$contrasena_usuario")" "$nombre_usuario"
      dialog --infobox "El usuario $nombre_usuario se ha creado exitosamente." 0 0
      sleep 2
    fi
  done < "usuarios.txt"
}

# Función para el código de la opción 2 (ALTA MANUAL DE USUARIOS)
opcion_2() {
  # Solicita la cantidad de usuarios a crear
  cantidad_usuarios=$(dialog --stdout --inputbox "Ingrese la cantidad de usuarios que desea crear:" 0 0)
  response=$?
  if [ $response -eq 1 ]; then
    return
  elif [ -z "$cantidad_usuarios" ]; then
    dialog --msgbox "No se proporcionó la cantidad de usuarios." 0 0
    return 1
  fi

  # Crea la interfaz de usuario para ingresar los datos de cada usuario
  usuarios=()
  for ((i=1; i<=$cantidad_usuarios; i++))
  do
    form=$(dialog --stdout --title "Crear Usuario $i" --form "Ingrese los datos para el usuario $i:" 0 0 0 \
      "Nombre de usuario:" 1 1 "" 1 25 30 0 \
      "Contraseña:" 2 1 "" 2 25 30 0)
    
    response=$?
    if [ $response -eq 1 ]; then
      return
    fi

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
      password=$(head -n1 "$respuesta")
      echo "$password" | sudo useradd -m -p "$(openssl passwd -1 "$contrasena_usuario")" "$nombre_usuario"
      dialog --infobox "El usuario $nombre_usuario se ha creado exitosamente." 0 0
      sleep 2
    fi
  done
}

# Función para el código de la opción 3 (CAMBIO MASIVO DE CONTRASEÑA)
opcion_3() {
  # Verifica si el archivo de usuarios existe
  if [ ! -f "cambiousuarios.txt" ]; then
    dialog --msgbox "El archivo cambiousuarios.txt no existe en el directorio actual." 0 0
    return
  fi

  # Lee cada línea del archivo y cambia la contraseña de cada usuario
  while IFS=: read -r nombre_usuario contrasena_nueva
  do
    # Verifica si el usuario existe
    if id "$nombre_usuario" &>/dev/null; then
      # Crea la interfaz de usuario para cambiar la contraseña utilizando la biblioteca ncurses
      exec 3>&1
      form=$(dialog --title "Cambio de Contraseña" --form "Ingrese la nueva contraseña para el usuario $nombre_usuario:" 0 0 0 \
        "Nueva Contraseña:" 1 1 "" 1 25 30 0 \
        "Confirmar Contraseña:" 2 1 "" 2 25 30 0 \
        2>&1 1>&3)
      exec 3>&-

      # Captura el código de salida de dialog
      exit_code=$?

      # Verifica el código de salida
      if [ $exit_code -eq 0 ]; then
        # Extrae la nueva contraseña del formulario
        contrasena_nueva=$(echo "$form" | awk 'NR==1{print $NF}')
        confirmar_contrasena=$(echo "$form" | awk 'NR==2{print $NF}')

        # Verifica que la contraseña y la confirmación coincidan
        if [ "$contrasena_nueva" == "$confirmar_contrasena" ]; then
          # Cambia la contraseña utilizando el comando passwd
          dialog --passwordbox "Ingresa la contraseña de sudo:" 8 40 --insecure 2> $respuesta
	password=$(head -n1 "$respuesta")
          echo -e "$password\n$contrasena_nueva\n$contrasena_nueva" | sudo passwd "$nombre_usuario"
          echo -e "$password\n$contrasena_nueva\n$contrasena_nueva"
          dialog --infobox "Se ha cambiado la contraseña del usuario $nombre_usuario." 0 0  # Muestra un mensaje de éxito utilizando la biblioteca ncurses
          sleep 2
        else
          dialog --msgbox "Las contraseñas no coinciden para el usuario $nombre_usuario. No se cambió la contraseña." 0 0  # Muestra un mensaje de error utilizando la biblioteca ncurses
        fi
      else
        dialog --msgbox "Operación cancelada por el usuario. No se cambió la contraseña." 0 0  # Muestra un mensaje de cancelación utilizando la biblioteca ncurses
      fi
    else
      dialog --msgbox "El usuario $nombre_usuario no existe. No se cambió la contraseña." 0 0  # Muestra un mensaje de error utilizando la biblioteca ncurses
    fi
  done < "cambiousuarios.txt"  # Redirecciona la entrada del bucle while para leer líneas del archivo de usuarios
}

# Función para el código de la opción 4 (CAMBIO DE CONTRASEÑAS MASIVO)
opcion_4() {
  # Importa la biblioteca ncurses
  if ! type "dialog" >/dev/null 2>&1; then
    dialog --msgbox "El programa 'dialog' no está instalado. Por favor, instálalo para utilizar la interfaz ncurses." 0 0
    return
  fi

  # Solicita la cantidad de usuarios a cambiar la contraseña
  cantidad_usuarios=$(dialog --stdout --inputbox "Ingrese la cantidad de usuarios a cambiar la contraseña:" 0 0)
  if [ -z "$cantidad_usuarios" ]; then
    dialog --msgbox "No se proporcionó la cantidad de usuarios." 0 0
    return
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

  # Crea la interfaz de usuario para confirmar el cambio de contraseña
  dialog --yesno "¿Desea cambiar la contraseña de los usuarios seleccionados?" 0 0

  # Captura el código de salida de dialog
  exit_code=$?

  # Verifica el código de salida
  if [ $exit_code -eq 0 ]; then
    # Cambia las contraseñas utilizando el comando passwd
    for usuario in "${usuarios[@]}"
    do
      nombre_usuario=$(echo "$usuario" | cut -d ":" -f 1)
      contrasena_nueva=$(echo "$usuario" | cut -d ":" -f 2)

      # Verifica si el usuario existe
      if id "$nombre_usuario" &>/dev/null; then
        # Cambia la contraseña utilizando el comando passwd
        dialog --passwordbox "Ingresa la contraseña de sudo:" 8 40 --insecure 2> $respuesta
	password=$(head -n1 "$respuesta")
        echo -e "$password\n$contrasena_nueva\n$contrasena_nueva" | sudo passwd "$nombre_usuario"
        dialog --infobox "Se ha cambiado la contraseña del usuario $nombre_usuario." 0 0
        sleep 2
      else
        dialog --msgbox "El usuario $nombre_usuario no existe. No se cambió la contraseña." 0 0
      fi
    done
  else
    dialog --msgbox "Cancelado. No se cambió la contraseña de los usuarios." 0 0
  fi
}

# Ciclo del menú principal
while true; do
  # Mostrar el menú y obtener la opción seleccionada
  opcion=$(dialog --menu "ADMINISTRACION DE USUARIOS" 15 60 5 \
    1 "ALTA MASIVA DE USUARIOS, VIA ARCHIVO DE TEXTO" \
    2 "ALTA MASIVO DE USUARIOS MANUAL" \
    3 "CAMBIO MASIVO DE CONTRASEÑA,VIA ARCHIVO DE TEXTO" \
    4 "CAMBIO MASIVO DE CONTRASEÑA MANUAL" \
    5 "VOLVER AL MENÚ PRINCIPAL" \
     2>&1 >/dev/tty) 
  # Tomar acciones en función de la opción seleccionada
  case $opcion in
    1)
      mostrar_opcion "INGRESANDO AL ALTA MASIVA DE USUARIOS, VIA ARCHIVO DE TEXTO"
      opcion_1
      ;;
    2)
      mostrar_opcion "INGRESANDO AL ALTA MANUAL DE USUARIOS"
      opcion_2
      ;;
    3)
      mostrar_opcion "INGRESANDO AL CAMBIO MASIVO DE CONTRASEÑA,VIA ARCHIVO DE TEXTO"
      opcion_3
      ;;
    4)
      mostrar_opcion "INGRESANDO AL CAMBIO MANUAL DE CONTRASEÑA MANUAL"
      opcion_4
      ;;
    5)
      mostrar_opcion "Regresando al menu principal"
     #El siguiente break se debe de quitar para cambiarlo por la parte de volver al menu principal
     break
      ;;
    *)
      mostrar_opcion "Opción inválida. Por favor, seleccione una opción válida."
      ;;
  esac
done
