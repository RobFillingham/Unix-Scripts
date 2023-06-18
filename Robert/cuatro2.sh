
new="new.txt" 
old="old.txt"
diferencia="diferencia.txt"
carpeta="EntradasSalidas.txt"
eol=""
users="usuarios.txt"
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
	cat $diferencia
	usuario=$(grep ">" $diferencia | cut -d" " -f2)
	echo "Usuario: $usuario"
	if $(grep -q "$usuario" $users) && [ "$usuario" != "$eol" ]
	then
		echo "in: $in"
		if [ "$in" != "$eol" ]
		then
			printf "$in\n" >> $carpeta
		fi
			
		
	
	else
		out=$(grep "<" $diferencia)
		usuario=$(grep "<" $diferencia | cut -d" " -f2)
		echo "out: $out"
		if [ "$out" != "$eol" ]
		then
			printf "$out\n" >> $carpeta
		fi
		

	fi
	echo "-----------------------"
	mv $new $old
	
	sleep 1
	
done 

