#!/bin/bash

dispositivos=$(lsblk -o NAME -n| sed -e 's/├─//g' -e 's/└─//g') #se utiliza lsblk para listar la info de los dispositivos por nombre 



habilitarCheck() {
    dispositivo=$1
    if grep -q "/dev/$dispositivo" /etc/fstab; then
        dialog --clear --msgbox "El chequeo de volúmenes ya está habilitado para /dev/$dispositivo" 8 60
    else
        sudo sed -i "s|^/dev/$dispositivo.*|/dev/$dispositivo\t/\tauto\tdefaults\t1 1|" /etc/fstab
        dialog --clear --msgbox "Chequeo de volúmenes habilitado para /dev/$dispositivo" 8 60
    fi
    return
}

deshabilitarCheck() {
    dispositivo=$1
    if grep -q "/dev/$dispositivo" /etc/fstab; then
         sudo sed -i "s|^/dev/$dispositivo.*|/dev/$dispositivo\t/\tauto\tdefaults\t0 0|" /etc/fstab
        dialog --clear --msgbox "Chequeo de volúmenes deshabilitado para /dev/$dispositivo" 8 60
    else
        dialog --clear --msgbox "El chequeo de volúmenes ya está deshabilitado para /dev/$dispositivo" 8 60
    fi
    return
}

HaInVolumenes() {
    dispositivos=$(lsblk -o NAME -n)
    for dispositivo in $dispositivos; do
        dialog --clear --backtitle "Habilitar o deshabilitar el chequeo de volúmenes para /dev/$dispositivo" \
        --yes-label "Habilitar" --no-label "Deshabilitar" --extra-button --extra-label "Regresar al menú" \
        --yesno "¿Qué acción deseas realizar?" 8 60

        case $? in
            0)
                habilitarCheck $dispositivo
                ;;
            1)
                deshabilitarCheck $dispositivo
                ;;
            3)
                return
                ;;
        esac
    done
    return
}

ModoMantenimiento() {
    # Función para arrancar en modo de mantenimiento (monousuario)

    dialog --title "Modo de Mantenimiento" --msgbox "Se cambiará al modo monousuario." 10 30

    tiempo_apagado=$(dialog --stdout --title "Modo de Mantenimiento" --inputbox "Ingrese el tiempo de apagado (en segundos):" 10 30)
    if [ -z "$tiempo_apagado" ]; then
        dialog --title "Error" --msgbox "No se ingresó ningún valor. Saliendo del modo de mantenimiento." 10 30
        return
    fi

    mensaje=$(dialog --stdout --title "Modo de Mantenimiento" --inputbox "Ingrese un mensaje para los usuarios:" 10 30)
    if [ -z "$mensaje" ]; then
        dialog --title "Error" --msgbox "No se ingresó ningún mensaje. Saliendo del modo de mantenimiento." 10 30
        return
    fi

    sudo init 1 # Cambiar a modo monousuario

    sudo wall "$mensaje" # Mostrar mensaje de mantenimiento a los usuarios

    sleep "$tiempo_apagado" # Esperar el tiempo especificado antes de apagar

    #shutdown now # Apagar el sistema
}



ModoManual() {
    # Función para arrancar en modo manual

    dialog --title "Modo Manual" --yesno "¿Desea arrancar en modo manual?" 10 30

    response=$?
    if [ $response -eq 0 ]; then
       sudo  init 5  # Cambiar al modo manual
    else
        dialog --title "Modo Manual" --msgbox "No se ha seleccionado el modo manual. Saliendo..." 10 30
    fi
}




CheckVolumenes() {
    # Función para chequear los volúmenes

    for dispositivo in $dispositivos; do
        dialog --title "Chequeo de Volumen" --yesno "¿Deseas hacer un chequeo de /dev/$dispositivo?" 10 30

        response=$?
        if [ $response -eq 0 ]; then
            dialog --title "Chequeo de Volumen" --infobox "Ejecutando fsck en /dev/$dispositivo..." 10 30
            output=$(mktemp)  # Crear un archivo temporal para almacenar la salida del fsck
           sudo fsck -y /dev/$dispositivo > $output 2>&1  # Ejecuta el fsck del volumen y redirige la salida al archivo temporal

            dialog --title "Chequeo de Volumen - Resultado" --textbox $output 20 60  # Muestra el contenido completo del archivo temporal en un cuadro de diálogo
            rm $output  # Elimina el archivo temporal
        elif [ $response -eq 1 ]; then
            deshabilitar_checkeo $dispositivo
            dialog --title "Chequeo de Volumen" --msgbox "Chequeo de /dev/$dispositivo saltado" 10 30
        else
            dialog --title "Chequeo de Volumen" --msgbox "Opción inválida. Saltando /dev/$dispositivo..." 10 30
        fi
    done

    dialog --title "Chequeo de Volumen" --msgbox "Chequeo de volúmenes completado" 10 30
}

# Definición de la función
MostrarUsoDisco() {
   dialog --title "Espacio en Disco" --stdout --msgbox "$(lsblk -o NAME,SIZE,TYPE,MOUNTPOINT | sed -e 's/├─//g' -e 's/└─//g'| awk 'BEGIN { printf "%-10s %-10s %-10s %s\n", "Dispositivo", "Tamaño", "Tipo", "Punto de Montaje" } { printf "%-10s %-10s %-10s %s\n", $1, $2, $3, $4 }')" 50 80
}



# Definición de la función
CrearFormatMontarVolumenes() {
    # Diálogo para ingresar el dispositivo
    dialog --title "Dispositivo" --inputbox "Ingresa el nombre del dispositivo (ejemplo: sda):" 10 50 2>dispositivo.tmp
    dispositivo=$(cat dispositivo.tmp)
    rm dispositivo.tmp
	echo "$dispositivo"
    # Diálogo para ingresar el tamaño de la partición
    dialog --title "Tamaño de la partición" --inputbox "Ingresa el tamaño de la partición (ejemplo: 85%):" 10 50 2>tamano.tmp
    tamano=$(cat tamano.tmp)
    rm tamano.tmp

    # Diálogo para ingresar el directorio de montaje
    dialog --title "Directorio de montaje" --inputbox "Ingresa el directorio de montaje:" 10 50 2>directorio.tmp
    directorio=$(cat directorio.tmp)
    rm directorio.tmp

    # Diálogo para ingresar la ruta de montaje
    dialog --title "Ruta de montaje" --inputbox "Ingresa la ruta de montaje:" 10 50 2>ruta.tmp
    ruta=$(cat ruta.tmp)
    rm ruta.tmp

    # Diálogos informativos
    dialog --infobox "Creando partición..." 10 50
    sudo parted -s /dev/$dispositivo mkpart primary ext4 0% $tamano

    dialog --infobox "Formateando partición..." 10 50
     sudo mkfs.ext4 /dev/${dispositivo}1

    dialog --infobox "Montando volumen en $ruta..." 10 50
   sudo mount /dev/${dispositivo}1 $ruta

    dialog --msgbox "Volumen creado, formateado y montado en $ruta" 10 50
}


while true; do
    opcion=$(dialog --backtitle "MENÚ" --title "---------- MENÚ ----------" \
    --menu "Seleccione una opción:" 15 50 7 \
    1 "Habilitar/Inhabilitar chequeo de volúmenes al arrancar" \
    2 "Arrancar en modo mantenimiento (monousuario)" \
    3 "Arrancar en modo manual" \
    4 "Chequear volúmenes" \
    5 "Crear, formato y montar volúmenes" \
    6 "Mostrar uso del disco" \
    7 "Salir" 3>&1 1>&2 2>&3)

    clear

    case $opcion in
        1) HaInVolumenes;;
        2) ModoMantenimiento;;
        3) ModoManual;;
        4) CheckVolumenes;;
        5) CrearFormatMontarVolumenes;;
        6) MostrarUsoDisco;;
        7) break;;
        *) dialog --title "Opción inválida" --msgbox "Opción inválida. Intente nuevamente." 8 40 8;;
        
    esac
done

