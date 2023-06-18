


BEGIN{
	
	OFS=" "
	print "archivo usuarios: ", archivoUsuarios
	split(archivoUsuarios, users, "\n")
	print users[1], users[2]
	
}


/>/{ 
	#for each que compara el primer campo(nombre del usuario que inicio sesion) con los que el usuario ha añadido a la lista de supervision)
	print $0
	for(usuario in users){
		if($2 == users[usuario]){
			print 1
			break
		}

	}
	
}





