#!/bin/bash

#new="/home/robert/Documentos/Proyecto/Unix-Scripts/Robert/new.txt" 
#old="/home/robert/Documentos/Proyecto/Unix-Scripts/Robert/old.txt"
#diferencia="/home/robert/Documentos/Proyecto/Unix-Scripts/Robert/diferencia.txt"
#carpeta="/home/robert/Documentos/Proyecto/Unix-Scripts/Robert/EntradasSalidas.txt"
#users="/home/robert/Documentos/Proyecto/Unix-Scripts/Robert/usuarios.txt"




new="/var/new.txt" 
old="/var/old.txt"
diferencia="/var/diferencia.txt"
carpeta="/var/EntradasSalidas.txt"
users="/var/usuarios.txt"



#new="new.txt" 
#old="old.txt"
#diferencia="diferencia.txt"
#carpeta="EntradasSalidas.txt"
#users="usuarios.txt"

eol=""



cont=0
who>$old 

if ! test -f "$carpeta"
then
	printf "\nE/S Usuario Terminal       Fecha\n" > $carpeta
fi


while [ 1 == 1 ]
do
	
	who > $new
	diff $old $new > $diferencia  
	
	in=$(grep ">" "$diferencia")
	
	#validar si es un usuario en supervision

	usuario=$(grep ">" $diferencia | cut -d" " -f2)

	if $(grep -q "$usuario" $users) && [ "$usuario" != "$eol" ]
	then

		if [ "$in" != "$eol" ]
		then
			printf "$in\n" >> $carpeta
			cont=$(expr $cont "+" 1)

		fi
			
		
	
	else
		out=$(grep "<" $diferencia)
		usuario=$(grep "<" $diferencia | cut -d" " -f2)
		if [ "$out" != "$eol" ]
		then
			printf "$out\n" >> $carpeta
			cont=$(expr $cont "+" 1)

		fi
		

	fi

	mv $new $old
	

	
	
	if [ $cont == 500 ]
	then
		printf "\nE/S Usuario Terminal       Fecha\n" > $carpeta
		cont=0

	fi	
	
	sleep 5
	
done 

