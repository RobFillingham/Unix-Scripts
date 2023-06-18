
new="new.txt" 
old="old.txt"
diferencia="diferencia.txt"
carpeta="/tmp/EntradasSalidas.txt"
eol=""
users="/tmp/usuarios.txt"
who>$old 

if ! test -f "$carpeta"
then
	printf "\n" > $carpeta
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
	if $(grep -q "$usuario" $users)
	then
		echo "in: $in"
		if [ "$in" != "$eol" ]
		then
			printf "$in\n" >> $carpeta
		fi
			
		out=$(grep "<" $diferencia)
		echo "out: $out"
		if [ "$out" != "$eol" ]
		then
			printf "$out\n" >> $carpeta
		fi
		
		echo "-----------------------"
	fi
	
	mv $new $old
	
	sleep 1
	
done 

