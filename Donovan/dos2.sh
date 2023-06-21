respuesta="stderr2.txt"
while true; do
    # Mostrar el menú utilizando ncurses
    opcion=$(dialog --clear --title "PROGRAMACION DE TAREAS DE FORMA MANUAL" \
        --menu "Selecciona una opción:" 15 50 4 \
        "1" "PROGRAMACION DE TAREAS DE FORMA MANUAL" \
        "2" "RESPALDO PROGRAMADO" \
        "3" "BORRADO TEMPORAL PROGRAMADO" \
        "4" "INHABILITACION DE USUARIOS POR PERIODO DE TIEMPO" \
        "5" "ANALIZAR ESTADO DE COMPUTADORA ANTI-VIRUS" \
        3>&1 1>&2 2>&3)

    # Realizar acciones según la opción seleccionada
    case $opcion in
            1)
            crontab -e
            dialog --title "PROGRAMACION DE TAREAS DE FORMA MANUAL" --msgbox "Las tareas fueron programadas correctamente" 10 60
            ;;
        2)
            dialog --title "RESPALDO PROGRAMADO" --msgbox "Comenzando el proceso de respaldo" 8 45
            fecha=$(date "+%d-%m-%y_%H-%M-%S")
            archivo="respaldo_$fecha.tar.gz"
            carpetaD="respaldos"
            respaldable="PruebasProyecto"
            mkdir -p "$carpetaD"
            tar cfvz "$carpetaD/$archivo" "$respaldable"
            dialog --title "PROGRAMACION DE TAREAS" --msgbox "El respaldo fue realizado con exito" 10 60
            ;;
        3)
            archivos_temporales="/tmp"
            patron="*.tmp"
            borrar=$(dialog --title "Programar borrado" --inputbox "Introduzca la hora en formato (24 horas) HH:MM para programar el borrado de archivos temporales" 10 60 3>&1 1>&2 2>&3)
            hora=$(date "+%H:%M")
		echo "$hora  -  $borrar"
            if [[ $hora == $borrar ]]; then
                if find "$archivos_temporales" -name "$patron" -delete; then
                    dialog --title "BORRADO TEMPORAL" --msgbox "El borrado de archivos temporales fue realizado con éxito" 10 60
                else
                    dialog --title "ERROR" --msgbox "Ocurrió un error durante el borrado de archivos temporales" 10 60
                fi
            fi
            ;;
        4)
            usuario=$(dialog --title "Usuario a inhabilitar:" --inputbox "Introduzca el usuario" 10 60 3>&1 1>&2 2>&3)

            if [ -z "$usuario" ]; then
                dialog --title "Inhabilitacion de usuarios" --msgbox "El usuario ingresado no existe" 10 60
            else
                if id "$usuario" >/dev/null 2>&1; then
                    tiempomh=$(dialog --title "Tiempo de inhabilitación" --inputbox "Introduzca el tiempo en minutos y horas (Ejemplo: 4h20m) para deshabilitar al usuario $usuario" 10 60 3>&1 1>&2 2>&3)

                    if [ -z "$tiempomh" ]; then
                        dialog --title "Inhabilitacion de usuarios" --msgbox "El tiempo no fue ingresado" 10 60
                    else
                        minutos=0
                        horas=0

                        if [[ $tiempomh == *h* ]]; then
                            horas=$(echo "$tiempomh" | sed 's/[^0-9]*//g')
                        fi

                        if [[ $tiempomh == *m* ]]; then
                            minutos=$(echo "$tiempomh" | sed 's/[^0-9]*//g')
                        fi

                        total_segundos=$((horas * 3600 + minutos * 60))
			
			dialog --passwordbox "Ingresa la contraseña de sudo:" 8 40 --insecure 2> $respuesta
			password=$(head -n1 "$respuesta")
                        echo "$password" | sudo passwd -l "$usuario"
                        dialog --title "Inhabilitacion de usuarios" --msgbox "El usuario $usuario ha sido inhabilitado por $tiempomh." 10 60
                        sleep "$total_segundos"
                        echo "$password" | sudo passwd -u "$usuario"
                        dialog --title "Inhabilitacion de usuarios" --msgbox "$usuario fue habilitado nuevamente." 10 60
                    fi
                else
                    dialog --title "Inhabilitacion de usuarios" --msgbox "El usuario $usuario no existe" 10 60
                fi
            fi
            ;;

        5)
            clamtk
            ;;
        *)
            break  # Salir del bucle si se selecciona una opción inválida o se presiona Cancelar
            ;;
    esac
done
