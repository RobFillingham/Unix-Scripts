respuestas="stderr.txt"

dialog --menu "Elige una opcion:" 10 50 3 1 "Agregar Usuario a Supervisar" 2 green 3 blue 2> $respuestas

opcion=$(head -n1 "$respuestas")

case "$opcion" in

	1) 
		dialog --inputbox "Ingresa el usuario:" 8 40 2>$respuestas
		usr=$(head -n1 "$respuestas")
		echo "$usr"
		#echo $(cat /etc/passwd | grep -q -w "$usr")
		if $(cat "/etc/passwd" | grep -q -w "$usr")
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
			dialog --title 'Supervision Usuario' --msgbox '\nEl usuario no existe!' 6 43			
		fi
	;;
	
		
	
esac	
