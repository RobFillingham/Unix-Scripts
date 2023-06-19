respuestas="stderr.txt"
comandos="comandos.txt"
recursos="recursos.txt"
opcion="1"
while [ $opcion -ne 5 ]
do
	dialog --menu "Elige una opcion:" 13 50 5 1 "Agregar Usuario a Supervisar" 2 "Mostrar Inicios de Sesion" 3 "HIstorial de Comandos" 4 "Consumo de Recursos" 5 "Salir" 2> $respuestas

	opcion=$(head -n1 "$respuestas")

	case "$opcion" in

		1) 
			dialog --inputbox "Ingresa el usuario:" 8 40 2>$respuestas
			usr=$(head -n1 "$respuestas")
			echo "$usr"
			#echo $(cat /etc/passwd | grep -q -w "$usr")
			if $(cat "/etc/passwd" | grep -q -w "$usr") && test -n "$usr"
			then
				#echo "user found"
				if $(grep -q -w "$usr" "usuarios.txt")
				then
					dialog --title 'Supervision Usuario' --msgbox '\nEl usuario ya esta siendo supervisado!' 6 43
				else
					printf "$usr\n" >> "usuarios.txt"
					dialog --title 'Supervision Usuario' --msgbox '\nEl usuario ha sido agregado a la lista de supervision!' 6 60				
				fi	
			else
				dialog --title 'Supervision Usuario' --msgbox '\nEl usuario no es valido!' 6 43			
			fi
		;;
		
		2)
			dialog --title "(Entrada > / Salida <)" --textbox "EntradasSalidas.txt" 50 70 
		;;
		
		3)	
			dialog --passwordbox "Ingresa la contraseña de sudo:" 8 40 --insecure 2>$respuestas
			password=$(head -n1 "$respuestas")
			dialog --inputbox "Ingresa un usuario:" 8 40 2>$respuestas
			usr=$(head -n1 "$respuestas")
			#tail -t "/home/${usr}/.bash_history" > comandos.txt
			echo "$password" | sudo -S tac "/home/${usr}/.bash_history" > comandos.txt
			dialog --title "Historial de Comandos de $usr"  --textbox "comandos.txt" 50 70 		
		;;
		4)
			dialog --inputbox "Ingresa el usuario:" 8 40 2>$respuestas
			usr=$(head -n1 "$respuestas")
			if $(cat "/etc/passwd" | grep -q -w $usr) && test -n "$usr"
			then
				echo "$usr"
				
				while [ $? == 0 ]
				do
					echo "$?"
					printf "\n" > $recursos
					printf "\nUSUARIO  TTY      DE               LOGIN@   IDLE   JCPU    PCPU WHAT\n\n" >>$recursos
					w | grep "$usr" >> $recursos
					dialog --title "Recursos siendo consumidos por $usr"  --begin 15 40 --tailboxbg "recursos.txt" 11 90 --and-widget --begin 25 40 --yesno "Actualizar?" 5 90
				done
			else
				dialog --title 'Supervision Usuario' --msgbox '\nEl usuario no es valido!' 6 43			
			fi
		;;
		
		5)
		
		;;
		
		*)
		
		;;
		
			
		
	esac	
	
done
