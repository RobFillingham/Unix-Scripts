respuestas="resp.txt"
opcion="1"



while [ "$opcion" != "6" ]
do
	dialog --menu "Elige una opcion:" 13 50 6 1 "Administracion Usuarios" 2 "Programacion de Tareas" 3 "Tareas de Mantenimiento Y Niveles de Arranque" 4 "Tareas SObre Usuarios En SEsion" 5 "Administrador de Paquetes" 6 "Salir" 2> $respuestas

	opcion=$(head -n1 "$respuestas")

	case "$opcion" in

		1) 
			source "Ruben/menu.sh"
		;;
		
		2)
			source "Donovan/dos2.sh"
		;;
		
		3)	
			source "Julio/Tres.sh"		
		;;
		4)
			source "Robert/menuRobert.sh"
		;;
		
		5)
			source "Robert/AdminPaquetes.sh"
		;;
		
		6)
		
		;;
		
		*)
		
		;;
		
			
		
	esac	
	
done
