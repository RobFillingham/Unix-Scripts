#!/bin/bash

respuesta="stderr2.txt"
opcion=0
listaPaquetes="listaPaquetes.txt"

while [ "$opcion" -ne "4" ]
do
	dialog --menu "Elige una opcion:" 13 50 5 1 "Instalar Paquete" 2 "Desinstalar Paquetes" 3 "Ver Paquetes Instalados" 4 "Salir" 2> $respuesta
	opcion=$(head -n1 "$respuesta")

	case "$opcion" in

		1)
			dialog --inputbox "Ingresa el nombre del paquete a instalar:" 8 40 2> $respuesta
			paquete=$(head -n1 "$respuesta")
			#echo "$paquete"
			dialog --passwordbox "Ingresa la contraseña de sudo:" 8 40 --insecure 2> $respuesta
			password=$(head -n1 "$respuesta")
			echo "$password" | sudo apt update > $respuesta
			echo "$password" | sudo apt install -y "$paquete" > $respuesta
			if [ "$?" -ne "0" ]
			then
				dialog --title 'Error' --msgbox "PAQUETE NO DISPONIBLE" 6 180
			else
				dialog --title 'Exito' --msgbox "Paquete instalado con exito" 6 80
			fi
			
		;;
		
		2)
			dialog --inputbox "Ingresa el nombre del paquete a desinstalar:" 8 40 2> $respuesta
			paquete=$(head -n1 "$respuesta")
			#echo "$paquete"
			dialog --passwordbox "Ingresa la contraseña de sudo:" 8 40 --insecure 2> $respuesta
			password=$(head -n1 "$respuesta")
			echo "$password" | sudo apt remove -y "$paquete" > $respuesta
			if [ "$?" -ne "0" ]
			then
				dialog --title 'Error' --msgbox "PAQUETE NO INSTALADO" 6 180
			else
				dialog --title 'Exito' --msgbox "Paquete desinstalado con exito" 6 80
			fi
			
		
		;;
		
		3)	
			dialog --inputbox "Ingresa el nombre del paquete a buscar:" 8 40 2> $respuesta
			paquete=$(head -n1 "$respuesta")
			apt list --installed | grep -w "$paquete" > "$listaPaquetes"
			linea=$(head -n1 "$respuesta")
			dialog --title "Resultados:" --textbox "$listaPaquetes" 5 80
			
			
		;;
		
		4)
		
		;;
		
		*)
		
		;;


	esac
done

