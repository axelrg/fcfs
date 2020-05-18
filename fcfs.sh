#!/bin/bash

#Nombre:		FCFS-SN-N-S_Rubio_Gonzalez_Axel.sh
#Descripcion: 	El script simula el funcionamiento de un algoritmo de gestión de procesos first coming first served 
#			  	con memoria según necesidades no continua y reubicable (FCFS-SN-N-S)
#Autor:		  	Áxel Rubio González
#Organización:	Universidad de Burgos


#Declaración de los arrays del programa
declare -a arr_tiempos_llegada
declare -a arr_tiempos_ejecucion
declare -a arr_memoria
declare -a nombres_procesos
declare -a arr_colores

declare -a ordenado_arr_tiempos_llegada
declare -a ordenado_arr_tiempos_ejecucion
declare -a ordenado_arr_memoria
declare -a ordenado_nombres_procesos
declare -a ordenado_arr_colores

#Estos arrays se usan para crear el fichero con los datos introducidos por teclado, si así lo desea el usuario
#El motivo por el cual creo este array es que los otros son ordenados (por tll) y este debe permanecer sin hacerlo.
declare -a arr_tiempos_llegada_fichero
declare -a arr_tiempos_ejecucion_fichero
declare -a arr_memoria_fichero

#Colores
declare -r DEFAULT='\e[39m' #Color por defecto
declare -r BLACK='\e[30m'
declare -r WHITE='\e[97m'

declare -r RED='\e[31m'
declare -r GREEN='\e[32m'
declare -r YELLOW='\e[33m'
declare -r BLUE='\e[34m'
declare -r MAGENTA='\e[35m'
declare -r CYAN='\e[36m'
declare -r L_GRAY='\e[36m' #Gris claro
declare -r L_RED='\e[91m' #Rojo claro
declare -r L_GREEN='\e[92m' #Verde claro
declare -r L_YELLOW='\e[93m' #Amarillo claro
declare -r L_BLUE='\e[94m' #Azul claro
declare -r L_MAGENTA='\e[95m' #Magenta claro
declare -r L_CYAN='\e[96m' #Cyan claro
declare -r D_GRAY='\e[90m' #Gris oscuro

#Esta variable guarda el limite superior de huecos en memoria hasta el cual se reubica
reubicabilidad=0
contador_colores=1


#Nombre:		array_colores
#Descripcion: 	Esta función se va a encargar de llenar el array con colores en función del número de procesos introducidos
#Autor:		  	Áxel Rubio González
#Organización:	Universidad de Burgos
function array_colores {
	arr_colores[$contador]="\e[3${contador_colores}m"
	contador_colores=$(($contador_colores+1))
	if [[ $contador_colores -eq 7 ]]; then
		contador_colores=1
	fi
}


#Nombre:		pregunto_si_otro_proceso_mas
#Descripcion: 	Esta función va a preguntar si quiero introducir otro proceso
#Autor:		  	Áxel Rubio González
#Organización:	Universidad de Burgos
function pregunto_si_otro_proceso_mas {
	echo "¿Quieres añadir otro proceso?"| tee -a informeColor.txt
	       		read "op"
	       		echo "$op" >> informeColor.txt
			until [ "$op" == "n" -o "$op" == "s" ]
				do
					echo "Respuesta introducida no válida"| tee -a informeColor.txt
					echo "Introduzca una respuesta que sea s/n"| tee -a informeColor.txt
					read "op"
					echo "$op" >> informeColor.txt
				done
}


#Nombre:		ordenar_arrays_por_Tll
#Descripcion: 	Esta función ordena los cinco arrays según el tiempo de llegada de cada proceso (de menor a mayor)
#Autor:		  	Áxel Rubio González
#Organización:	Universidad de Burgos
function ordenar_arrays_por_Tll {
	#contador guarda el número de procesos
	for (( t = 1; t <= $contador; t++ )); do

		min=1000 #1000 es un numero que hace imposible que  haya uno menor

		for (( i = 1; i <= $contador; i++ )); do

			if [ ${arr_tiempos_llegada[$i]} -lt "$min" ]; then
				min="${arr_tiempos_llegada[$i]}"
				Posicion="$i"
			fi
		done

		#en cada ejecución del bucle se copia el elemento que ha establecido como menor
		#en la posición correspondiente en el array ordenado
		ordenado_arr_tiempos_llegada[$t]=${arr_tiempos_llegada[$Posicion]}
		ordenado_arr_tiempos_ejecucion[$t]=${arr_tiempos_ejecucion[$Posicion]}
		ordenado_arr_memoria[$t]=${arr_memoria[$Posicion]}
		ordenado_nombres_procesos[$t]=${nombres_procesos[$Posicion]}
		ordenado_arr_colores[$t]=${arr_colores[$Posicion]}

		#echo "Min is: $min"
		#echo "Posicion min es arr_tiempos_llegada[$Posicion]"
		#echo "${arr_tiempos_llegada[$Posicion]}"

		#ese elemento menor se cambia su valor a 1000 para que no entre en la siguiente
		#iteracion del bucle
		arr_tiempos_llegada[$Posicion]="1000"
			
		####################
	done
}



#Nombre:		copiar_arrays
#Descripcion: 	Esta función copia el contenido de los vectores ordenados a los desordenados
#Autor:		  	Áxel Rubio González
#Organización:	Universidad de Burgos
function copiar_arrays {
	for (( i = 1; i <= $contador; i++ )); do
		arr_tiempos_llegada[$i]=${ordenado_arr_tiempos_llegada[$i]}
		arr_tiempos_ejecucion[$i]=${ordenado_arr_tiempos_ejecucion[$i]}
		arr_memoria[$i]=${ordenado_arr_memoria[$i]}
		nombres_procesos[$i]=${ordenado_nombres_procesos[$i]}
		arr_colores[$i]=${ordenado_arr_colores[$i]}
	done
}



#Nombre:		copia_inversa_arrays
#Descripcion: 	Esta función copia el contenido de los vectores desordenados a los ordenados
#Autor:		  	Áxel Rubio González
#Organización:	Universidad de Burgos
function copia_inversa_arrays {
	for (( i = 1; i <= $contador; i++ )); do
		ordenado_arr_tiempos_llegada[$i]=${arr_tiempos_llegada[$i]}
		ordenado_arr_tiempos_ejecucion[$i]=${arr_tiempos_ejecucion[$i]}
		ordenado_arr_memoria[$i]=${arr_memoria[$i]}
		ordenado_nombres_procesos[$i]=${nombres_procesos[$i]}
		ordenado_arr_colores[$i]=${arr_colores[$i]}
	done
}



#Nombre:		imprimir_tabla_datos
#Descripcion: 	Esta función imprime una primera version de la tabla de datos NO SE USA EN LA VERSION FINAL
#Autor:		  	Áxel Rubio González
#Organización:	Universidad de Burgos
function imprimir_tabla_datos {
	printf " REF TLL TEJ MEM\n"
	for (( i = 1; i <= $contador; i++ )); do
		printf " ${ordenado_arr_colores[$i]}%-*s %-*s %-*s %-*s $DEFAULT\n" 3 ${ordenado_nombres_procesos[$i]} 3 ${ordenado_arr_tiempos_llegada[$i]} 3 ${ordenado_arr_tiempos_ejecucion[$i]} 3 ${ordenado_arr_memoria[$i]}
	done
}


#Nombre:		entrada_por_teclado
#Descripcion: 	Esta función llena los arrays de datos con lo que introduzca el usuario, también genera los nombres automaticos
#Autor:		  	Áxel Rubio González
#Organización:	Universidad de Burgos
function entrada_por_teclado {
	op="s"
	contador=1
	echo "Introduce el tamaño de la memoria"| tee -a informeColor.txt
	read tamanio_memoria
	echo "$tamanio_memoria">> informeColor.txt
	echo "Introduce el numero hasta el cual se reubica"| tee -a informeColor.txt
	read reubicabilidad
	echo "$tamanio_memoria">> informeColor.txt
	echo "El tamaño de la memoria es $tamanio_memoria"| tee -a informeColor.txt
	while [ "$op" == "s" ]; do

			arr_tiempos_llegada[$contador]="-"
			arr_tiempos_ejecucion[$contador]="-"
			arr_memoria[$contador]="-"

			if [ $contador -gt 9 ]; then
				nombres_procesos[$contador]="P$contador"
			fi
			
			if [ $contador -lt 10 ]; then
				nombres_procesos[$contador]="P0$contador"
			fi
			array_colores
			copia_inversa_arrays
			#echo "${arr_tiempos_llegada[@]}"
			#echo "${arr_tiempos_ejecucion[@]}"
			#echo "${arr_memoria[@]}"
			#echo "${nombres_procesos[@]}"
			#echo "${arr_colores[@]}"
			clear
			imprimir_tabla_datos| tee -a informeColor.txt
			echo "Tiempo de llegada ${nombres_procesos[$contador]}:"| tee -a informeColor.txt
			read tiempo_llegada
			echo "$tiempo_llegada">> informeColor.txt
			arr_tiempos_llegada[$contador]=$tiempo_llegada
			arr_tiempos_llegada_fichero[$contador]=$tiempo_llegada

			copia_inversa_arrays
			clear
			imprimir_tabla_datos
			echo "Tiempo de ejecución ${nombres_procesos[$contador]}:"| tee -a informeColor.txt
			read tiempo_ejecucion
			echo "$tiempo_ejecucion">> informeColor.txt
			arr_tiempos_ejecucion[$contador]=$tiempo_ejecucion
			arr_tiempos_ejecucion_fichero[$contador]=$tiempo_ejecucion

			copia_inversa_arrays
			clear
			imprimir_tabla_datos
			echo "Memoria ${nombres_procesos[$contador]}:"| tee -a informeColor.txt
			read memoria
			echo "$memoria">> informeColor.txt
			arr_memoria[$contador]=$memoria
			arr_memoria_fichero[$contador]=$memoria

			ordenar_arrays_por_Tll
			copiar_arrays

			#echo "${arr_tiempos_llegada[@]}"
			#echo "${arr_tiempos_ejecucion[@]}"
			#echo "${arr_memoria[@]}"
			#echo "${nombres_procesos[@]}"
			#echo "${arr_colores[@]}"

			clear
			imprimir_tabla_datos| tee -a informeColor.txt
			pregunto_si_otro_proceso_mas

			if [ "$op" == "s" ]; then
				contador=$(($contador+1))
			fi
	done
}



#Nombre:		entrada_aleatoria
#Descripcion: 	Esta función llena los arrays de datos aleatoriamente, también genera los nombres automaticos
#Autor:		  	Áxel Rubio González
#Organización:	Universidad de Burgos
function entrada_aleatoria {
	tamanio_memoria=$((RANDOM%99))
	reubicabilidad=$((RANDOM%6))
	echo "El tamaño de la memoria es $tamanio_memoria"
	echo "El numero hasta el cual se reubica es $reubicabilidad"
	echo "¿Cuántos procesos quieres crear?"
	read procesos_a_crear
	contador=1
	while [ $procesos_a_crear -ge $contador ]; do

			arr_tiempos_llegada[$contador]=$((RANDOM%99))
			arr_tiempos_ejecucion[$contador]=$(((RANDOM%98)+1))
			limite_superior_mem=$(($tamanio_memoria-1))
			arr_memoria[$contador]=$(((RANDOM%$limite_superior_mem)+1))


			if [ $contador -gt 9 ]; then
				nombres_procesos[$contador]="P$contador"
			fi
			
			if [ $contador -lt 10 ]; then
				nombres_procesos[$contador]="P0$contador"
			fi

			array_colores
			ordenar_arrays_por_Tll
			copiar_arrays

			contador=$(($contador+1))

	done

	if [ $contador -gt $procesos_a_crear ]; then
		contador=$procesos_a_crear
	fi
}


#Nombre:		corte_datos
#Descripcion: 	Esta función llena los arrays con los datos del fichero introducido, también genera los nombres automaticos
#Autor:		  	Áxel Rubio González
#Organización:	Universidad de Burgos
function corte_datos {
	cd FICHEROS_ENTRADA
	tamanio_memoria=`sed -n 1p $fichero_entrada | cut -d ":" -f 2`
	reubicabilidad=`sed -n 2p $fichero_entrada | cut -d ":" -f 2`
	#echo "El tamaño de la memoria es $tamanio_memoria"

	for (( contador = 1; contador <= $(($procesos_en_fichero+3)); contador++ )); do
		arr_tiempos_llegada[$contador]=`sed -n $(($contador+3))p $fichero_entrada | cut -d ":" -f 1`
		arr_tiempos_ejecucion[$contador]=`sed -n $(($contador+3))p $fichero_entrada | cut -d ":" -f 2`
		arr_memoria[$contador]=`sed -n $(($contador+3))p $fichero_entrada | cut -d ":" -f 3`
		if [ $contador -gt 9 ]; then
			nombres_procesos[$contador]="P$contador"
		fi
		
		if [ $contador -lt 10 ]; then
			nombres_procesos[$contador]="P0$contador"
		fi
		array_colores
	done

	if [ $contador -gt $procesos_en_fichero ]; then
		contador=$procesos_en_fichero
	fi

	cd ../		
}


#Nombre:		corte_datos
#Descripcion: 	Esta función realiza la entrada por fichero, pide un fichero al usuario y con corte_datos coge los datos de ese fichero
#Autor:		  	Áxel Rubio González
#Organización:	Universidad de Burgos
function entrada_por_fichero {
	echo "Ficheros en el directorio FICHEROS_ENTRADA"
	cd FICHEROS_ENTRADA
	ls
	cd ../
	echo "Escribe el fichero del que deseas extraer los datos:"
	read fichero_entrada
	procesos_en_fichero=(`wc -l ./FICHEROS_ENTRADA/$fichero_entrada`)
	procesos_en_fichero=$(($procesos_en_fichero-2))
	echo "El numero de líneas del fichero es $procesos_en_fichero"
	contador=$procesos_en_fichero
	corte_datos
}


#Nombre:		menu_entrada
#Descripcion: 	Esta función imprime un menú para dar a elegir al usuario como quiere introducir los datos
#Autor:		  	Áxel Rubio González
#Organización:	Universidad de Burgos
function menu_entrada {

	echo "Elige una de las opciones para introducir los datos:" | tee -a informeColor.txt
	echo "1-> Entrada por teclado"| tee -a informeColor.txt
	echo "2-> Generar datos aleatorios"| tee -a informeColor.txt
	echo "3-> Leer desde un archivo"| tee -a informeColor.txt
	read opcion_menu_datos

	case $opcion_menu_datos in
		1)
			echo "Has elegido entrada por teclado:"| tee -a informeColor.txt
			entrada_por_teclado
			
		;;

		2)
			echo "Has elegido generar los datos aleatoriamente:"| tee -a informeColor.txt
			entrada_aleatoria
			
		;;

		3)
			echo "Has elegido lectura desde archivo:"| tee -a informeColor.txt
			entrada_por_fichero
			
			#echo "${arr_colores[@]}"
			ordenar_arrays_por_Tll
			copiar_arrays
			

			#echo "${nombres_procesos[@]}"
			#echo "${arr_tiempos_llegada[@]}"
			#echo "${arr_tiempos_ejecucion[@]}"
			#echo "${arr_memoria[@]}"
		;;

		*)
			echo "ERROR"| tee -a informeColor.txt
		;;
	esac
}


#Nombre:		inicializar_array_memoria
#Descripcion: 	Esta función escribe en el array de memoria tantos ceros como el tamaño de la memoria
#Autor:		  	Áxel Rubio González
#Organización:	Universidad de Burgos
function inicializar_array_memoria {
	for (( i = 0 ; i <=$tamanio_memoria ; i++ )); do
		array_memoria[$i]=0
	done
	#Despues de la ultima dirección de la memoria en el array guardo este numero para poder saber donde ha acabado
	uno=$(($tamanio_memoria + 1))
	array_memoria[$uno]=1000
}


#Nombre:		inicializar_array_tiempo_restante
#Descripcion: 	Esta función escribe en el array tiempo restante tantos - como procesos 
#Autor:		  	Áxel Rubio González
#Organización:	Universidad de Burgos
function inicializar_array_tiempo_restante {
	array_tiempo_restante[0]=10000
	for (( i = 1 ; i <= $contador ; i++ )); do
		array_tiempo_restante[$i]="-"
	done
}


#Nombre:		inicializar_array_tiempo_espera
#Descripcion: 	Esta función escribe en el array tiempo espera tantos - como procesos 
#Autor:		  	Áxel Rubio González
#Organización:	Universidad de Burgos
function inicializar_array_tiempo_espera {
	for (( i = 1 ; i <= $contador ; i++ )); do
		array_tiempo_espera[$i]="-"
	done
}



#Nombre:		inicializar_array_tiempo_espera
#Descripcion: 	Esta función escribe en el array tiempo retorno tantos - como procesos 
#Autor:		  	Áxel Rubio González
#Organización:	Universidad de Burgos
function inicializar_array_tiempo_retorno {
	for (( i = 1 ; i <= $contador ; i++ )); do
		array_tiempo_retorno[$i]="-"
	done
}



#Nombre:		inicializar_array_estado
#Descripcion: 	Esta función escribe en el array tiempo espera tantos "Fuera del sistema" como procesos 
#Autor:		  	Áxel Rubio González
#Organización:	Universidad de Burgos
function inicializar_array_estado {
	for (( i = 1 ; i <= $contador ; i++ )); do
		array_estado[$i]="Fuera del sistema"
	done
}


#Nombre:		imprimir_tabla
#Descripcion: 	Esta función imprime la tabla con los tiempos
#Autor:		  	Áxel Rubio González
#Organización:	Universidad de Burgos
function imprimir_tabla {
	printf " Ref Tll Tej Mem | Tes Trt Tre Estado\n"
	for (( i = 1; i <= $contador; i++ )); do
		printf " ${ordenado_arr_colores[$i]}%-*s %-*s %-*s %-*s $DEFAULT|${ordenado_arr_colores[$i]} %-*s %-*s %-*s %-*s $DEFAULT\n" 3 "${ordenado_nombres_procesos[$i]}" 3 "${ordenado_arr_tiempos_llegada[$i]}" 3 "${ordenado_arr_tiempos_ejecucion[$i]}" 3 "${ordenado_arr_memoria[$i]}" 3 "${array_tiempo_espera[$i]}" 3 "${array_tiempo_retorno[$i]}" 3 "${array_tiempo_restante[$i]}" 3 "${array_estado[$i]}"
	done
}


#Nombre:		anadirCola
#Descripcion: 	Esta función mete en el array cola los procesos que entren al sistema
#Autor:		  	Áxel Rubio González
#Organización:	Universidad de Burgos
function anadirCola {
	((tamCola++))
	cola[$tamCola]=$proceso
	array_estado[$proceso]="En espera"
	cambio_a_imprimir=1
	array_tiempo_espera[$proceso]=0
	array_tiempo_retorno[$proceso]=0
}



#Nombre:		eliminarCola
#Descripcion: 	Esta función mueve todos los elementos en cola a la posicion anterior y elimina uno
#Autor:		  	Áxel Rubio González
#Organización:	Universidad de Burgos
function eliminarCola {
	local -i i
	for(( i = 1; i <= tamCola; i++ )); do
		cola[$i]=${cola[$i+1]}
	done
	((tamCola--))
}


#Nombre:		anadirMemoria
#Descripcion: 	Esta función escribe en el array memoria tantos identificadores del proceso como huecos ocupe en memoria
#				Ejemplo:
#				tamaño memoria =9
#				3: ocupa 5 en memoria, le meto, estaba el 2 con 3 espacios 
#
#				Posiciones en el array: 	0 1 2 3 4 5 6 7 8 9 10
#				Contenido en la posicion:	0 2 2 2 3 3 3 3 3 0 1000
#
#				La posicion 0 no se utiliza y la 10 guarda 1000 que indica el final del array
#
#Autor:		  	Áxel Rubio González
#Organización:	Universidad de Burgos
function anadirMemoria {
	#Esta variable se encarga de que en memoria metamos solo los indices que ocupa el proceso
	contador_memoria=0
	proceso_a_meter_en_memoria=${cola[1]}
	for (( i = 1; i <=$tamanio_memoria ; i++ )); do
		if [[ ${array_memoria[$i]} -eq 0 ]] && [[ $contador_memoria -lt ${ordenado_arr_memoria[$proceso_a_meter_en_memoria]} ]]; then
			#echo "Antes de meter_en_memoria:${array_memoria[$i]}"
			array_memoria[$i]=$proceso_a_meter_en_memoria

			#echo "Despues de meter_en_memoria:${array_memoria[$i]}"
			((contador_memoria++))
		fi	
	done
	cambio_a_imprimir=1
	array_estado[$proceso_a_meter_en_memoria]="En memoria"
	array_tiempo_restante[$proceso_a_meter_en_memoria]=${ordenado_arr_tiempos_ejecucion[$proceso_a_meter_en_memoria]}
}


#Nombre:		eliminarMemoria
#Descripcion: 	Esta función elimina de la memoria el proceso en ejecucion
#Autor:		  	Áxel Rubio González
#Organización:	Universidad de Burgos
function eliminarMemoria {
	for (( i = 1; i <=$tamanio_memoria ; i++ )); do

		if [[ ${array_memoria[$i]} -eq $proceso_en_ejecucion ]]
		then
			#echo "Antes de igualar:${array_memoria[$i]}"
			array_memoria[$i]=0
			#echo "Despues de igualar:${array_memoria[$i]}"
		fi
	done
}

#Nombre:		buscar_en_memoria
#Descripcion: 	Esta función busca en memoria que proceso (de los que estan en memoria) ha llegado antes al sistema
#Autor:		  	Áxel Rubio González
#Organización:	Universidad de Burgos
function buscar_en_memoria {
	primero_en_llegar=1000
	#echo Memoria busq:
	#echo ${array_memoria[@]}
	for (( i = 1; i <= $tamanio_memoria ; i++ )); do
		if [[ ${array_memoria[$i]} -lt $primero_en_llegar ]] && [[ ${array_memoria[$i]} -ne 0 ]]
	     then
	        primero_en_llegar=${array_memoria[$i]}
	        #echo $primero_en_llegar
	    fi
	done
	if [[ $primero_en_llegar -ne 0 ]]; then
		echo "$primero_en_llegar"
	fi	
}


#Nombre:		buscar_en_memoria
#Descripcion: 	Calcula cuantos espacios con un 0 quedan en memoria
#Autor:		  	Áxel Rubio González
#Organización:	Universidad de Burgos
function calcular_memoria_restante {
	memoria_restante=0
	for (( i = 1; i <= $tamanio_memoria ; i++ )); do
		if [[ ${array_memoria[$i]} -eq 0 ]]; then
			((memoria_restante++))
		fi
	done
}

#Nombre:		imprimir_mem
#Descripcion: 	NO SE USA EN LA VERSION FINAL Imprime el array memoria
#Autor:		  	Áxel Rubio González
#Organización:	Universidad de Burgos
function imprimir_mem {
	#echo MEMORIA
	for (( i = 1; i <=$tamanio_memoria ; i++ )); do
		echo -n "${array_memoria[$i]}"
	done
	echo ""
}


#Nombre:		imprimir_linea_temporal
#Descripcion: 	NO SE USA EN LA VERSION FINAL Imprime la linea temporal (con huecos con color)
#Autor:		  	Áxel Rubio González
#Organización:	Universidad de Burgos
function imprimir_linea_temporal {
	printf "BT|"
	for (( i = 0; i <= $(($tiempo-1)); i++ )); do
		printf "${ordenado_arr_colores[${array_linea_temporal[$i]}]}\u2593\u2593\u2593$DEFAULT"
	done
		printf "|$tiempo"
	
	echo ""
}


#Nombre:		imprimir_linea_memoria
#Descripcion: 	NO SE USA EN LA VERSION FINAL Imprime la linea de memoria (con huecos con color)
#Autor:		  	Áxel Rubio González
#Organización:	Universidad de Burgos
function imprimir_linea_memoria {
	printf "BM|"
	for (( i = 1; i <= $tamanio_memoria; i++ )); do
		printf "${ordenado_arr_colores[${array_memoria[$i]}]}\u2593\u2593\u2593$DEFAULT"
	done
	printf "|$tamanio_memoria"
	echo ""
}


#Nombre:		tiempo_linea_temporal
#Descripcion: 	genera el array que guarda 3 espacios o el tiempo dependiendo de si se debe imprimir o no
#Autor:		  	Áxel Rubio González
#Organización:	Universidad de Burgos
function tiempo_linea_temporal {
	tiempo_linea_temporal[0]="  0"
	for (( i = 1; i <= $tiempo; i++ )); do
		if [[ ${array_linea_temporal[$i]} -ne ${array_linea_temporal[$(($i - 1))]} ]] && [[ $procesos_ejecutados -ne $contador ]]; then

			if [[ $i -lt 10 ]] && [[ $i -ne 10 ]]; then
				tiempo_linea_temporal[$i]="  $i"
			else
				if [[ $i -le 99 ]]; then
					tiempo_linea_temporal[$i]=" $i"
				else
					tiempo_linea_temporal[$i]="$i"
				fi
			fi


		fi

		if [[ ${array_linea_temporal[$i]} -eq ${array_linea_temporal[$(($i - 1))]} ]]; then
			tiempo_linea_temporal[$i]="   "
		fi

		if [[ $i -eq $tiempo ]] && [[ ${array_linea_temporal[$i]} -ne ${array_linea_temporal[$(($i - 1))]} ]]; then
			if [[ $procesos_ejecutados -ne $contador ]]; then
				
			
				tiempo_linea_temporal[$i]=""


				if [[ $i -lt 10 ]] && [[ $i -ne 10 ]]; then
					tiempo_linea_temporal[$i]="  $i"
				else
					if [[ $i -le 99 ]]; then
						tiempo_linea_temporal[$i]=" $i"
					else
						tiempo_linea_temporal[$i]="$i"
					fi
				fi
			fi
		fi
	done
}

#Nombre:		imprimir_tiempo_linea_temporal
#Descripcion: 	NO SE USA EN LA VESION FINAL imprime el tiempo de la linea temporal
#Autor:		  	Áxel Rubio González
#Organización:	Universidad de Burgos
function imprimir_tiempo_linea_temporal {
	printf "   "
	for (( i = 0; i <= $tiempo; i++ )); do
		printf "${tiempo_linea_temporal[$i]}"
	done
}


#Nombre:		procesos_linea_temporal
#Descripcion: 	genera el array que guarda 3 espacios o el nombre de proceso dependiendo de si se debe imprimir o no
#Autor:		  	Áxel Rubio González
#Organización:	Universidad de Burgos
function procesos_linea_temporal {

	for (( i = 0; i <= $tiempo; i++ )); do
		if [[ ${array_linea_temporal[$i]} -ne ${array_linea_temporal[$(($i - 1))]} ]] && [[ $procesos_ejecutados -ne $contador ]]; then
			procesos_linea_temporal[$i]="${ordenado_nombres_procesos[${array_linea_temporal[$i]}]}"	
		fi

		if [[ ${array_linea_temporal[$i]} -eq ${array_linea_temporal[$(($i - 1))]} ]]; then
			 procesos_linea_temporal[$i]="   "
		fi

		#if [[ $i -eq $tiempo ]]; then
		#	procesos_linea_temporal[$i]="${ordenado_nombres_procesos[${array_linea_temporal[$i]}]}"
		#fi

		if [[ $i -eq $tiempo ]] && [[ ${array_linea_temporal[$i]} -ne ${array_linea_temporal[$(($i - 1))]} ]] && [[ $procesos_ejecutados -ne $contador ]]; then
			procesos_linea_temporal[$i]=""
			procesos_linea_temporal[$i]="${ordenado_nombres_procesos[${array_linea_temporal[$i]}]}"
		fi

		if [[ $i -eq 0 ]]; then
			procesos_linea_temporal[$i]="${ordenado_nombres_procesos[${array_linea_temporal[$i]}]}"	
		fi
	done

	#if [[ ${array_linea_temporal[0]} -ne 0 ]]; then
	#	procesos_linea_temporal[0]="${ordenado_nombres_procesos[${array_linea_temporal[0]}]}"	
	#fi
#
#	#if [[ ${array_linea_temporal[0]} -eq 0 ]]; then
#	#	procesos_linea_temporal[0]="   "
	#fi

	#procesos_linea_temporal[0]="${ordenado_nombres_procesos[${array_linea_temporal[]}]}"

}


#Nombre:		imprimir_procesos_linea_temporal
#Descripcion: 	NO SE USA EN LA VESION FINAL imprime los procesos en la linea temporal
#Autor:		  	Áxel Rubio González
#Organización:	Universidad de Burgos
function imprimir_procesos_linea_temporal {
	printf "   "
	for (( i = 0; i <= $tiempo; i++ )); do
		printf "${ordenado_arr_colores[${array_linea_temporal[$i]}]}${procesos_linea_temporal[$i]}$DEFAULT"
	done
	echo ""

}


#Nombre:		direcciones_linea_memoria
#Descripcion: 	genera el array que guarda 3 espacios o la direccion de memoria dependiendo de si se debe imprimir o no
#Autor:		  	Áxel Rubio González
#Organización:	Universidad de Burgos
function direcciones_linea_memoria {

	for (( i = 1; i <= $tamanio_memoria; i++ )); do
		if [[ $i -ne 1 ]]; then
			if [[ ${array_memoria[$i]} -ne ${array_memoria[$(($i - 1))]} ]]; then
				

				if [[ $(($i - 1)) -lt 10 ]]; then
					direcciones_linea_memoria[$i]="  $(($i - 1))"
				fi

				if [[ $(($i - 1)) -ge 10 ]]; then
					direcciones_linea_memoria[$i]=" $(($i - 1))"
				fi	
			fi

			if [[ ${array_memoria[$i]} -eq ${array_memoria[$(($i - 1))]} ]]; then
				direcciones_linea_memoria[$i]="   "
			fi

			if [[ $i -eq $tamanio_memoria ]]; then

				if [[ $(($i - 1)) -lt 10 ]]; then
					direcciones_linea_memoria[$(($i + 1))]="  $i"
				fi

				if [[ $(($i - 1)) -ge 10 ]]; then
					direcciones_linea_memoria[$(($i + 1))]=" $i"
				fi
			fi
		fi
	done
}


#Nombre:		imprimir_direcciones_linea_memoria
#Descripcion: 	NO SE USA EN LA VESION FINAL imprime las DM en la linea memoria
#Autor:		  	Áxel Rubio González
#Organización:	Universidad de Burgos
function imprimir_direcciones_linea_memoria {
	printf "   "
	printf "0  "
	for (( i = 0; i <= $tamanio_memoria; i++ )); do
		printf "${direcciones_linea_memoria[$i]}"
	done
}


#Nombre:		procesos_linea_memoria
#Descripcion: 	genera el array que guarda 3 espacios o el nombre del proceso dependiendo de si se debe imprimir o no
#Autor:		  	Áxel Rubio González
#Organización:	Universidad de Burgos
function procesos_linea_memoria {


	for (( i = 1; i <= $(($tamanio_memoria + 1)); i++ )); do

		if [[ ${array_memoria[$i]} -ne ${array_memoria[$(($i - 1))]} ]]; then
			procesos_linea_memoria[$i]="${ordenado_nombres_procesos[${array_memoria[$i]}]}"	
		fi

		if [[ ${array_memoria[$i]} -eq ${array_memoria[$(($i - 1))]} ]]; then
			procesos_linea_memoria[$i]="   "
		fi

		if [[ $i -eq 1 ]]; then
			procesos_linea_memoria[$i]="${ordenado_nombres_procesos[${array_memoria[$i]}]}"	
		fi

	done

	#if [[ ${array_memoria[1]} -ne 0 ]]; then
	#	procesos_linea_memoria[1]="${ordenado_nombres_procesos[${array_memoria[1]}]}"	
	#fi

	#if [[ ${array_memoria[1]} -eq 0 ]]; then
	#	procesos_linea_memoria[1]="---"
	#fi

	#procesos_linea_memoria[1]="${ordenado_nombres_procesos[${array_memoria[1]}]}"
}


#Nombre:		imprimir_procesos_linea_memoria
#Descripcion: 	NO SE USA EN LA VESION FINAL imprime los nombres de procesos en la linea memoria
#Autor:		  	Áxel Rubio González
#Organización:	Universidad de Burgos
function imprimir_procesos_linea_memoria {
	printf "   "
	for (( i = 0; i <=$tamanio_memoria; i++ )); do
		printf "${ordenado_arr_colores[${array_memoria[$i]}]}${procesos_linea_memoria[$i]}$DEFAULT"
	done
	echo ""
}


#Nombre:		reubicamos
#Descripcion: 	funcion que realiza la reubicabilidad
#Autor:		  	Áxel Rubio González
#Organización:	Universidad de Burgos
function reubicamos {
	
	for (( i = 0 ; i <=$tamanio_memoria ; i++ )); do
		array_memoria_ord[$i]=0
	done

	for (( i = 1; i <= $tamanio_memoria; i++ )); do
		minimo=1000
		for (( j = 1; j <= $tamanio_memoria; j++ )); do

			if [[ ${array_memoria[$j]} -lt "$minimo" ]] && [[ ${array_memoria[$j]} -ne 0 ]]; then
				minimo=${array_memoria[$j]}
				posicion=$j
				
			fi
		done
		array_memoria_ord[$i]=${array_memoria[$posicion]}
		array_memoria[$posicion]="0"
	done

	inicializar_array_memoria

	for (( i = 1; i <= $tamanio_memoria; i++ )); do
		array_memoria[$i]=${array_memoria_ord[$i]}
	done

	

	#for (( i = 1; i <= $tamanio_memoria; i++ )); do
	#	array_memoria[$i]=${array_memoria_ord[$i]}
	#done
}


#Nombre:		gg_necesito_reubicar
#Descripcion: 	comprueba si es necesario reubicar
#Autor:		  	Áxel Rubio González
#Organización:	Universidad de Burgos
function gg_necesito_reubicar {
	contador_reubicar=0
	necesito_reubicar=0


	for (( i = 1; i <= $(($tamanio_memoria + 1)) ; i++ )); do
		#if [[ ${array_memoria[$i]} -ne 0 ]]; then
			
		
			if [[ $i -eq 1 ]]; then
				((contador_reubicar++))
			fi

			if [[ $i -ne 1 ]]; then
				if [[ ${array_memoria[$i]} -eq ${array_memoria[$(($i - 1))]} ]]; then
					((contador_reubicar++))
				fi

				if [[ ${array_memoria[$i]} -ne ${array_memoria[$(($i - 1))]} ]]; then
					if [[ $contador_reubicar -le $reubicabilidad ]]; then
						#if [[ ${ordenado_arr_memoria[${array_memoria[$(($i - 1))]}]} -gt $contador_reubicar ]]; then
							if [[ ${array_memoria[$(($i - 1))]} -eq 0 ]]; then
								necesito_reubicar=0
								reubicamos
								necesito_reubicar=1
							fi

							contador_reubicar=1
						#fi
						
					fi
					contador_reubicar=1
						#if [[ $contador_reubicar -gt 1 ]]; then
						#	contador_reubicar=0
						#	((contador_reubicar++))
						#fi
				fi
			fi
		#fi
	done

}


#Nombre:		llenar_direcciones_memoria
#Descripcion: 	llena tres arrays , uno con el proceso, otro con su Dinicial y otro con su Dfinal
#Autor:		  	Áxel Rubio González
#Organización:	Universidad de Burgos
function llenar_direcciones_memoria {
	contador_dir=0
	contador_partes_de_procesos_en_mem=0
	for (( i = 1; i <=  $(($tamanio_memoria +1)); i++ )); do 
		#if [[ ${array_memoria[$i]} -ne 0 ]]; then
			if [[ $i -eq 1 ]] ; then
				((contador_dir++))
				
			else
				if [[ ${array_memoria[$i]} -eq ${array_memoria[$(($i - 1))]} ]]  ; then
					((contador_dir++))
				fi

				if [[ ${array_memoria[$i]} -ne ${array_memoria[$(($i - 1))]} ]]; then
					direcciones_memoria_proceso[$contador_partes_de_procesos_en_mem]=${array_memoria[$(($i - 1))]}
					direcciones_memoria_inicial[$contador_partes_de_procesos_en_mem]=$(($i - $(($contador_dir + 1))))
					direcciones_memoria_final[$contador_partes_de_procesos_en_mem]=$(($i - 2))
					contador_dir=1
					contador_partes_de_procesos_en_mem=$(($contador_partes_de_procesos_en_mem +1))
				fi

			fi
			
			
		#fi
	done
}


#Nombre:		tabla_con_DM
#Descripcion: 	imprime la tabla final con las DM, si el proceso está en varios lugares en memoria imprime varias lineas
#Autor:		  	Áxel Rubio González
#Organización:	Universidad de Burgos
function tabla_con_DM {
	printf " Ref Tll Tej Mem | Tesp Tret Trej Mini Mfin Estado\n"
	for (( i = 1; i <= $contador; i++ )); do
		

		if [[ ${array_estado[$i]} == "Finalizado" ]] || [[ ${array_estado[$i]} == "En espera" ]] || [[ ${array_estado[$i]} == "Fuera del sistema" ]]; then
			printf " ${ordenado_arr_colores[$i]}%*s %*s %*s %*s $DEFAULT|${ordenado_arr_colores[$i]} %*s %*s %*s %*s %*s %*s $DEFAULT\n" 3 "${ordenado_nombres_procesos[$i]}" 3 "${ordenado_arr_tiempos_llegada[$i]}" 3 "${ordenado_arr_tiempos_ejecucion[$i]}" 3 "${ordenado_arr_memoria[$i]}" 4 "${array_tiempo_espera[$i]}" 4 "${array_tiempo_retorno[$i]}" 4 "${array_tiempo_restante[$i]}" 4 "-" 4 "-" 4 "${array_estado[$i]}"
		else

		#if [[ ${array_estado[$i]} == "En memoria" ]] || [[ ${array_estado[$i]} == "En ejecucion" ]]; then
			#echo $i
			proceso_detectado=$i
			contador_parejas_direcciones_proceso=0
			while [[ $proceso_detectado -eq $i ]]; do
				for (( j = 0; j <= $contador_partes_de_procesos_en_mem; j++ )); do
					if [[ ${direcciones_memoria_proceso[$j]} -ne 0 ]]; then
						if [[ ${direcciones_memoria_proceso[$j]} -eq $i ]]; then
							#echo $j
							((contador_parejas_direcciones_proceso++))
							proceso_detectado=${direcciones_memoria_proceso[$j]}
							#echo $proceso_detectado
							#Con este if imprimo todos los datos si es la primera pareja de DM, si no lo es inprimo solo las parejas de DM
							if [[ $contador_parejas_direcciones_proceso -eq 1 ]]; then
								printf " ${ordenado_arr_colores[$i]}%*s %*s %*s %*s $DEFAULT|${ordenado_arr_colores[$i]} %*s %*s %*s %*s %*s %*s $DEFAULT\n" 3 "${ordenado_nombres_procesos[$i]}" 3 "${ordenado_arr_tiempos_llegada[$i]}" 3 "${ordenado_arr_tiempos_ejecucion[$i]}" 3 "${ordenado_arr_memoria[$i]}" 4 "${array_tiempo_espera[$i]}" 4 "${array_tiempo_retorno[$i]}" 4 "${array_tiempo_restante[$i]}" 4 "${direcciones_memoria_inicial[$j]}" 4 "${direcciones_memoria_final[$j]}" 4 "${array_estado[$i]}"
							else
								printf " ${ordenado_arr_colores[$i]}%*s %*s %*s %*s $DEFAULT ${ordenado_arr_colores[$i]} %*s %*s %*s %*s %*s %*s $DEFAULT\n" 3 "   " 3 "   " 3 "   " 3 "   " 4 "    " 4 "    " 4 "    " 4 "${direcciones_memoria_inicial[$j]}" 4 "${direcciones_memoria_final[$j]}" 4 "    "
							fi
							direcciones_memoria_proceso[$j]=1000
						else
							proceso_detectado=1000
						fi
					fi
				done
			done
		
		fi


	done
}


#Nombre:		tiempos_medios
#Descripcion: 	calcula los tiempos medios
#Autor:		  	Áxel Rubio González
#Organización:	Universidad de Burgos
function tiempos_medios {
	procesos_media=0
	tiempo_medio_espera_acumulado=0
	tiempo_medio_retorno_acumulado=0

	for (( i = 1; i <= $contador ; i++ )); do
		if [[ ${array_estado[$i]} != "Fuera del sistema" ]]; then
			((procesos_media++))
			tiempo_medio_espera_acumulado=$((tiempo_medio_espera_acumulado + array_tiempo_espera[$i]))
			#echo $tiempo_medio_espera
			tiempo_medio_retorno_acumulado=$((tiempo_medio_retorno_acumulado + array_tiempo_retorno[$i]))
		fi
	done
	if [[ $procesos_media -ne 0 ]] && [[ $tiempo_medio_espera_acumulado -ne 0 ]]; then
		tiempo_medio_espera=$(echo "scale=2;$tiempo_medio_espera_acumulado/$procesos_media" | bc -l)
	fi
	if [[ $procesos_media -ne 0 ]] && [[ $tiempo_medio_retorno_acumulado -ne 0 ]]; then
		tiempo_medio_retorno=$(echo "scale=2;$tiempo_medio_retorno_acumulado/$procesos_media" | bc -l)
	fi
}


#Nombre:		truncado_memoria
#Descripcion: 	Esta función imprime la barra de memoria cortandola para que en caso de que se necesite otra linea coincida la impresión de
#				los 3 arrays, el de procesos, la barra y el de direcciones
#Autor:		  	Áxel Rubio González
#Organización:	Universidad de Burgos
function truncado_memoria {

	#Esta variable guarda las columnas que tiene el terminal 
	ancho_terminal="$(tput cols)"
	#En esta variable guardo los elementos (cada uno de 3 columnas) que caben en cada linea
	elementos_por_linea=$(($(($ancho_terminal/3))-2))
	#echo "elementos por linea:$elementos_por_linea"
	#En esta variable guardo el numero de lineas a imprimir
	lineas=$(($(($tamanio_memoria/$elementos_por_linea))+1))
	#echo "lineas:$lineas"
	ultima_posicion_impresa=0
	for (( j = 1; j <= $lineas; j++ )); do
		if [[ $j -ne 1 ]]; then
			printf "\n"
		fi

		if [[ $j -eq 1 ]]; then
			printf "   |"
		else
			printf "    "
		fi
		for (( i = $(($ultima_posicion_impresa+1)); i <=$(($elementos_por_linea*$j)); i++ )); do
			if [[ $i -le $tamanio_memoria ]]; then
				printf "${ordenado_arr_colores[${array_memoria[$i]}]}${procesos_linea_memoria[$i]}$DEFAULT"
			fi
		done
		echo ""
		if [[ $j -eq 1 ]]; then
			printf " BM|"
		else
			printf "    "
		fi
		for (( i = $(($ultima_posicion_impresa+1)); i <=$(($elementos_por_linea*$j)); i++ )); do
			if [[ $i -le $tamanio_memoria ]]; then
				printf "${ordenado_arr_colores[${array_memoria[$i]}]}\u2593\u2593\u2593$DEFAULT"
			fi
			
		done
		if [[ $j -eq $lineas ]]; then
			printf "$tamanio_memoria"
		fi
		
		echo ""

		
		if [[ $j -eq 1 ]]; then
			printf "   |"
			printf "  0"
		else
			printf "    "
		fi
		for (( i = $(($ultima_posicion_impresa+1)); i <=$(($elementos_por_linea*$j)); i++ )); do
			if [[ $i -le $tamanio_memoria ]]; then
				printf "${direcciones_linea_memoria[$i]}"
			fi
			
		done
		ultima_posicion_impresa=$(($(($elementos_por_linea*$j))))
	done
}

#Nombre:		truncado_tiempo
#Descripcion: 	Esta función imprime la barra de tiempo cortandola para que en caso de que se necesite otra linea coincida
#				la impresión de los 3 arrays, el de procesos, la barra y el de tiempo
#Autor:		  	Áxel Rubio González
#Organización:	Universidad de Burgos
function truncado_tiempo {

	#Esta variable guarda las columnas que tiene el terminal 
	ancho_terminal="$(tput cols)"
	#En esta variable guardo los elementos (cada uno de 3 columnas) que caben en cada linea
	elementos_por_linea=$(($(($ancho_terminal/3))-2))
	#echo "elementos por linea:$elementos_por_linea"
	#En esta variable guardo el numero de lineas a imprimir
	lineas=$(($(($tiempo/$elementos_por_linea))+1))
	#echo "lineas:$lineas"
	ultima_posicion_impresa=0
	for (( j = 1; j <= $lineas; j++ )); do
		if [[ $j -ne 1 ]]; then
			printf "\n"
		fi

		if [[ $j -eq 1 ]]; then
			printf "   |"
		else
			printf "    "
		fi

		for (( i = $(($ultima_posicion_impresa)); i <=$(($(($elementos_por_linea*$j))-1)); i++ )); do
			if [[ $i -le $tiempo ]]; then
				printf "${ordenado_arr_colores[${array_linea_temporal[$i]}]}${procesos_linea_temporal[$i]}$DEFAULT"
			fi
		done
		echo ""
		if [[ $j -eq 1 ]]; then
			printf " BT|"
		else
			printf "    "
		fi
		for (( i = $(($ultima_posicion_impresa)); i <=$(($(($elementos_por_linea*$j))-1)); i++ )); do
			if [[ $i -lt $tiempo ]]; then
				printf "${ordenado_arr_colores[${array_linea_temporal[$i]}]}\u2593\u2593\u2593$DEFAULT"
			fi
			
		done
		if [[ $j -eq $lineas ]]; then
			if [[ ${array_linea_temporal[$tiempo]} -eq ${array_linea_temporal[$(($tiempo-1))]} ]] || [[ $procesos_ejecutados -eq $contador ]]; then
				if [[ $tiempo -ne 0 ]]; then
					printf "$tiempo"
				fi
				
			fi
		fi
		
		echo ""
		
		if [[ $j -eq 1 ]]; then
			printf "   |"
			#printf "0  "
		else
			printf "    "
		fi
		for (( i = $(($ultima_posicion_impresa)); i <=$(($(($elementos_por_linea*$j))-1)); i++ )); do
			if [[ $i -le $tiempo ]]; then
				printf "${tiempo_linea_temporal[$i]}"
			fi
			
		done
		ultima_posicion_impresa=$(($(($elementos_por_linea*$j))))
	done
}


#Nombre:		crear_fichero_entrada
#Descripcion: 	Esta función crea un fichero con los datos de entrada
#Autor:		  	Áxel Rubio González
#Organización:	Universidad de Burgos
function crear_fichero_entrada {
	echo "Escribe el nombre del fichero de entrada a crear:"
	read fichero_datos_salida
	echo "MEM:$tamanio_memoria">>$fichero_datos_salida
	echo "REU:$reubicabilidad">>$fichero_datos_salida
	echo "TLL:TEJ:MEM">>$fichero_datos_salida
	for (( i = 1; i <= $contador; i++ )); do
		if [[ $i -eq $contador ]]; then
			echo -n "${arr_tiempos_llegada_fichero[$i]}:${arr_tiempos_ejecucion_fichero[$i]}:${arr_memoria_fichero[$i]}">>$fichero_datos_salida
		else
			echo "${arr_tiempos_llegada_fichero[$i]}:${arr_tiempos_ejecucion_fichero[$i]}:${arr_memoria_fichero[$i]}">>$fichero_datos_salida

		fi
	done
	mv $fichero_datos_salida FICHEROS_ENTRADA
}

#Nombre:		bucle_principal_script
#Descripcion: 	Esta función coordina todas las tareas del funcionamiento del algoritmo
#Autor:		  	Áxel Rubio González
#Organización:	Universidad de Burgos
function bucle_principal_script {
	declare -a cola
	declare -a array_estado
	declare -a array_tiempo_restante
	declare -a array_tiempo_espera
	declare -a array_tiempo_retorno
	#Estos arrays se encargan de calcular los elementos de la linea de memoria
	declare -a array_memoria
	declare -a direcciones_linea_memoria
	declare -a procesos_linea_memoria
	#Estos arrays se encargan de calcular los elementos de la linea de tiempo
	declare -a array_linea_temporal
	declare -a tiempo_linea_temporal
	declare -a procesos_linea_temporal
	#Este es un array bidimensional encargado de guardar en la columna 1 el proceso y en las dos siguientes la DIn y la DFi
	declare -a direcciones_memoria
	declare -a direcciones_memoria_final
	declare -a direcciones_memoria_inicial
	declare -a direcciones_memoria_proceso

	ordenado_nombres_procesos[0]="---"
	ordenado_arr_colores[0]="$DEFAULT"
	unset direcciones_memoria_proceso
	unset direcciones_memoria_inicial
	unset direcciones_memoria_final

	contador_partes_de_procesos_en_mem=0



	proceso=1
	tamCola=0
	proceso_en_ejecucion=0
	tiempo=-1
	procesos_ejecutados=0
	tiempo_medio_espera=0
	tiempo_medio_retorno=0

	inicializar_array_tiempo_espera
	inicializar_array_tiempo_restante
	inicializar_array_estado
	inicializar_array_tiempo_retorno
	inicializar_array_memoria

	while [[ $procesos_ejecutados -lt $contador ]]; do
		((tiempo++))
		cambio_a_imprimir=0
		#echo Tiempo=$tiempo

		if [[ $proceso_en_ejecucion -ne 0 ]] && [[ $tiempo -ne 0 ]]; then
			array_tiempo_restante[$proceso_en_ejecucion]=$((${array_tiempo_restante[$proceso_en_ejecucion]}-1))
		fi

		if [[ ${array_tiempo_restante[$proceso_en_ejecucion]} -eq 0 ]]; then
			if [[ $proceso_en_ejecucion != 0 ]]; then
				#echo $proceso_en_ejecucion
				((procesos_ejecutados++))
			fi

			array_estado[$proceso_en_ejecucion]="Finalizado"
			cambio_a_imprimir=1
			array_tiempo_retorno[$proceso_en_ejecucion]=$((${array_tiempo_retorno[$proceso_en_ejecucion]}+1))
			#array_tiempo_espera[$proceso_en_ejecucion]=$((${array_tiempo_espera[$proceso_en_ejecucion]}+1))
			#array_tiempo_retorno[$proceso_en_ejecucion]=$tiempo
			eliminarMemoria


			#echo Memoria despues de EM:
			#echo "eliminar"
			#imprimir_mem
			proceso_en_ejecucion=0
		fi


		for (( j = 1; j<=$contador ; j++ )); do
			#echo ${ordenado_arr_tiempos_llegada[$j]}
			if [[ $tiempo -eq ${ordenado_arr_tiempos_llegada[$j]} ]]; then
			proceso=$j
			anadirCola
			#echo ${cola[@]}
			#echo ${array_estado[@]}
			fi
		done

		
		primero_en_cola=${cola[1]}
		calcular_memoria_restante

		while [[ $memoria_restante -ge ${ordenado_arr_memoria[$primero_en_cola]} ]] && [[ $tamCola -gt 0 ]]; do
			primero_en_cola=${cola[1]}
			calcular_memoria_restante
			if [[ $memoria_restante -ge ${ordenado_arr_memoria[$primero_en_cola]} ]] && [[ $tamCola -gt 0 ]]; then
				gg_necesito_reubicar
				anadirMemoria
				#echo "añadir"
				#imprimir_mem
				eliminarCola

				
			fi
		done	
		
		#Condicional encargado de meter procesos a CPU
		if [[ $proceso_en_ejecucion -eq 0 ]]; then
			proceso_en_ejecucion=$(buscar_en_memoria)
			if [[ $proceso_en_ejecucion  -gt 100 ]]; then
				proceso_en_ejecucion=0
			fi
			#echo "buscar"
			#imprimir_mem
			#echo EN EJ: $proceso_en_ejecucion
			if [[ $tiempo -ne 0 ]] && [[ $tiempo -ne ${ordenado_arr_tiempos_llegada[$proceso_en_ejecucion]} ]]; then
				array_tiempo_espera[$proceso_en_ejecucion]=$((${array_tiempo_espera[$proceso_en_ejecucion]}+1))
			fi

			array_estado[$proceso_en_ejecucion]="En ejecucion"
			if [[ $proceso_en_ejecucion -ne 0 ]]; then
				cambio_a_imprimir=1
			fi
			

		fi

		#Con esto actualizo unidad de tiempo a unidad de tiempo la LINEA TEMPORAL

			direcciones_linea_memoria
			procesos_linea_memoria
			
			array_linea_temporal[$tiempo]=$proceso_en_ejecucion
			tiempo_linea_temporal
			procesos_linea_temporal
		
		#Bucle encargado de calcular el TIEMPO DE RETORNO
		for (( i = 1; i <= $contador ; i++ )); do
			if [[ ${array_estado[$i]} == "En memoria" ]] || [[ ${array_estado[$i]} == "En espera" ]] || [[ ${array_estado[$i]} == "En ejecucion" ]]; then
				if [[ $tiempo -ne ${ordenado_arr_tiempos_llegada[$i]} ]]; then
					array_tiempo_retorno[$i]=$((${array_tiempo_retorno[$i]}+1))
				fi
			fi

		done

		#Bucle encargado de calcular el TIEMPO EN ESPERA
		for (( i = 1; i <= $contador ; i++ )); do
			if [[ ${array_estado[$i]} == "En memoria" ]] || [[ ${array_estado[$i]} == "En espera" ]]; then
				if [[ $tiempo -ne ${ordenado_arr_tiempos_llegada[$i]} ]]; then
					array_tiempo_espera[$i]=$((${array_tiempo_espera[$i]}+1))
				fi
			fi

		done

		for (( i = 1; i <= $contador; i++ )); do
			if [[ ${array_tiempo_restante[$i]} != "-" ]]; then
				if [[ ${array_tiempo_restante[$i]} -eq 0 ]]; then
					array_tiempo_restante[$i]="-"
				fi
			fi
		done

		llenar_direcciones_memoria

		tiempos_medios
		
		#echo Tiempo=$tiempo

		#echo Cola:
		#echo ${cola[@]}
		#echo "P_EN_EJ:${proceso_en_ejecucion}"
		#echo "P_EJECUTADOS:${procesos_ejecutados}"
		#echo "Tamanio memoria: $tamanio_memoria"
		#echo Linea Temporal:
		#echo ${array_linea_temporal[@]}

		if [[ $cambio_a_imprimir -eq 1 ]] && [[ $tiempo -ge ${ordenado_arr_tiempos_llegada[1]} ]] ||  [[ $tiempo -eq 0 ]] || [[ $procesos_ejecutados -eq $contador ]] ; then
			clear
			echo " FCFS-SN-NC-R"
			echo " T=$tiempo    Marcos Reubicabilidad=$reubicabilidad    MEMtotal=$tamanio_memoria"
				
			#echo "$ancho_terminal"
			#echo "R=$reubicabilidad"
			
			#imprimir_tabla
			#echo ""
			tabla_con_DM

			
			#echo "LINEA MEMORIA:"
			#echo "${#array_memoria[@]}"
			#echo "${array_memoria_ord[@]}"
			#echo "${cola[@]}"
			#echo "${array_memoria[@]}"

			if [[ $necesito_reubicar -eq 1 ]]; then
				echo -e " \e[31m\e[1m\e[106mSE HA REUBICADO LA MEMORIA\u2757\u2757\e[49m\e[39m\e[0m"
				necesito_reubicar=0
			fi
			#imprimir_mem
			#echo "Tamaño memoria = $tamanio_memoria"
			#echo "${procesos_linea_memoria[@]}"
			#echo "partes: $contador_partes_de_procesos_en_mem"

			#echo "${direcciones_memoria[@]}"

			#for (( i = 1; i <= $contador_partes_de_procesos_en_mem; i++ )); do
			#	echo "${direcciones_memoria_proceso[@]}"
			#	echo "${direcciones_memoria_inicial[@]}"
			#	echo "${direcciones_memoria_final[@]}"
			#done
			printf " TIEMPO MEDIO ESPERA = $tiempo_medio_espera "
			printf "TIEMPO MEDIO RETORNO = $tiempo_medio_retorno\n"
			echo "$procesos_ejecutados"
			truncado_memoria
			#imprimir_procesos_linea_memoria
			#imprimir_linea_memoria
			#echo "${direcciones_linea_memoria[@]}"
			#imprimir_direcciones_linea_memoria
			echo ""
			#echo $procesos_media
		
			
			#echo "LINEA TEMPORAL:"
			#echo ${array_linea_temporal[@]}
			
			#echo ${tiempo_linea_temporal[@]}
			#if [[ $tiempo -eq 0 ]]; then
			#	printf "   |\n"
			#	printf " BT|\n"
			#	printf "   |"
			#fi

			if [[ $tiempo -ge 0 ]]; then
				#echo "${tiempo_linea_temporal[@]}"
				truncado_tiempo
				
				#echo ""
				#imprimir_procesos_linea_temporal
				#imprimir_linea_temporal
				#imprimir_tiempo_linea_temporal
			fi
			

			echo ""
			read -ers -p " Pulse [intro] para continuar la ejecucion"
			
		fi
		
		for (( i = 1; i <= $contador_partes_de_procesos_en_mem; i++ )); do
			direcciones_memoria_proceso[$i]=0
			direcciones_memoria_inicial[$i]=0
			direcciones_memoria_final[$i]=0

		done

	done

	#imprimir_tabla
	#echo ${cola[@]}
	#echo ${array_estado[@]}
}


#Nombre:		quitar_clear
#Descripcion: 	Esta función quita los clear del fichero a color
#Autor:		  	Áxel Rubio González
#Organización:	Universidad de Burgos
function quitar_clear {
	sed -i 's/\x1b\[3J//g' informeColor.txt
	sed -i 's/\x1b\[2J//g' informeColor.txt
	sed -i 's/\x1b\[H//g' informeColor.txt
	#sed -i 's/\x1b\[3J\x1b\[2J\x1b\[H//g' informePrueba.txt no va
}


#Nombre:		pasar_fichero_a_BN
#Descripcion: 	Esta función copia el fichero a color a otro en blanco y negro
#Autor:		  	Áxel Rubio González
#Organización:	Universidad de Burgos
function pasar_fichero_a_BN {
	sed -r "s/\x1B\[(([0-9]{1,2})?(;)?([0-9]{1,2})?)?[m,K,H,f,J]//g" informeColor.txt > informeBN.txt
}


#Nombre:		portada
#Descripcion: 	Esta función imprime la portada en consola y en los ficheros
#Autor:		  	Áxel Rubio González
#Organización:	Universidad de Burgos
function portada {
	clear 
	#Las siguientes lineas van a aparecer en el informe y en la consola durante la ejecucion gracias a "tee -a"
	echo "      ############################################################"| tee -a informeColor.txt
	echo "      #                     Creative Commons                     #"| tee -a informeColor.txt
	echo "      #                                                          #"| tee -a informeColor.txt
	echo "      #                   BY - Atribución (BY)                   #"| tee -a informeColor.txt
	echo "      #                 NC - No uso Comercial (NC)               #"| tee -a informeColor.txt
	echo "      #                SA - Compartir Igual (SA)                 #"| tee -a informeColor.txt
	echo "      ############################################################"| tee -a informeColor.txt
	echo "">>informeColor.txt
	echo "">>informeColor.txt
	#Las siguientes lineas solo van a aparecer en el informe gracias a ">>"
	echo "      #######################################################################">> informeColor.txt
	echo "      #                                                                     #">> informeColor.txt
	echo "      #                         INFORME DE PRÁCTICA                         #">> informeColor.txt
	echo "      #                         GESTIÓN DE PROCESOS                         #">> informeColor.txt
	echo "      #---------------------------------------------------------------------#">> informeColor.txt
	echo "      #     Algoritmo:FCFS-SN-N-S                                           #">> informeColor.txt
	echo "      #     Último Alumno: Áxel Rubio González                              #">> informeColor.txt
	echo "      #                                                                     #">> informeColor.txt
	echo "      #     Alumnos Anteriores:                                             #">> informeColor.txt
	echo "      #        Víctor Paniagua Santana                                      #">> informeColor.txt
	echo "      #        Enzo Argeñal                                                 #">> informeColor.txt
	echo "      #        Hector Cogollos y Luis Miguel Cabrejas                       #">> informeColor.txt
	echo "      #        Omar Santos Bernabé                                          #">> informeColor.txt
	echo "      #---------------------------------------------------------------------#">> informeColor.txt
	echo "      #              Sistemas Operativos 2º Semestre                        #">> informeColor.txt
	echo "      #              Grado en ingeniería informática (2019-2020)            #">> informeColor.txt
	echo "      #                                                                     #">> informeColor.txt
	echo "      #######################################################################">> informeColor.txt
	
	echo ""
	echo ""
	echo -e "\e[31m        /= = = = = = = = = = = = = = = = = = = = = = = = = = = =\\"
	echo -e "\e[31m       /= = = = = = = = = = = = = = = = = = = = = = = = = = = = =\\"
	echo -e "\e[31m      ||                                                         ||\e[39m"
	echo -e "\e[31m      ||   FCFS-SN-N-S:                                          ||\e[39m"
	echo -e "\e[31m      ||        -FCFS:First Coming First Served                  ||\e[39m"
	echo -e "\e[31m      ||        -SN:Según Necesidades                            ||\e[39m"
	echo -e "\e[31m      ||        -N:Memoria no Continua                           ||\e[39m"
	echo -e "\e[31m      ||        -S:Memoria Reubicable                            ||\e[39m"
	echo -e "\e[31m      ||                                                         ||\e[39m"
	echo -e "\e[31m      ||   AUTOR:                                                ||\e[39m"
	echo -e "\e[31m      ||        -Áxel Rubio González                             ||\e[39m"
	echo -e "\e[31m      ||                                                         ||\e[39m"
	echo -e "\e[31m      ||   VERSIÓN:                                              ||\e[39m"
	echo -e "\e[31m      ||        -Abril 2020                                      ||\e[39m"
	echo -e "\e[31m      ||                                                         ||\e[39m"
	echo -e "\e[31m       \\= = = = = = = = = = = = = = = = = = = = = = = = = = = = =/\e[39m"
	echo -e "\e[31m        \\= = = = = = = = = = = = = = = = = = = = = = = = = = = =/\e[39m"
	
	read -ers -p "Pulse [intro] para continuar la ejecucion"

}


#Nombre:		portada
#Descripcion: 	Esta funcion es la encargada de llamar a la entrada, al bucle principal y a los informes/salida
#Autor:		  	Áxel Rubio González
#Organización:	Universidad de Burgos
function principal {
	#Esta variable guarda el numero maximo de partes de procesos con las que se reubica
	reubicabilidad=0

	opcion_menu_datos=0
	rm informeColor.txt
	rm informeBN.txt
	portada
	clear
	echo ""
	menu_entrada 
	if [[ $opcion_menu_datos -eq 1 ]]; then
		crear_fichero_entrada
	fi
	#imprimir_tabla_datos
	bucle_principal_script | tee -a informeColor.txt
	quitar_clear
	pasar_fichero_a_BN
}

#Llamada a la función anterior
principal