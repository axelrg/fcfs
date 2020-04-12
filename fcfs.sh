#!/bin/bash

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


contador_colores=1
#Esta función se va a encargar de llenar el array con colores en función 
#del número de procesos introducidos
function array_colores {
	arr_colores[$contador]="\e[3${contador_colores}m"
	contador_colores=$(($contador_colores+1))
	if [[ $contador_colores -eq 7 ]]; then
		contador_colores=1
	fi
}

function pregunto_si_otro_proceso_mas {
	echo "¿Quieres añadir otro proceso?"
	       		read "op"
			until [ "$op" == "n" -o "$op" == "s" ]
				do
					echo "Respuesta introducida no válida"
					echo "Introduzca una respuesta que sea s/n"
					read "op"
				done
}

function ordenar_arrays_por_Tll {
	#contador guarda el número de procesos en los arrays
	for (( t = 1; t <= $contador; t++ )); do

		min=1000 #1000 es un numero que hace imposible que  haya uno menor

			for (( i = 1; i <= $contador; i++ )); do

				#FIXME: Revisar SI SE ORDENA POR EL NOMBRE DEL PROCESO
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

function copiar_arrays {
	for (( i = 1; i <= $contador; i++ )); do
		arr_tiempos_llegada[$i]=${ordenado_arr_tiempos_llegada[$i]}
		arr_tiempos_ejecucion[$i]=${ordenado_arr_tiempos_ejecucion[$i]}
		arr_memoria[$i]=${ordenado_arr_memoria[$i]}
		nombres_procesos[$i]=${ordenado_nombres_procesos[$i]}
		arr_colores[$i]=${ordenado_arr_colores[$i]}
	done
}

function copia_inversa_arrays {
	for (( i = 1; i <= $contador; i++ )); do
		ordenado_arr_tiempos_llegada[$i]=${arr_tiempos_llegada[$i]}
		ordenado_arr_tiempos_ejecucion[$i]=${arr_tiempos_ejecucion[$i]}
		ordenado_arr_memoria[$i]=${arr_memoria[$i]}
		ordenado_nombres_procesos[$i]=${nombres_procesos[$i]}
		ordenado_arr_colores[$i]=${arr_colores[$i]}
	done
}

function imprimir_tabla_datos {
	printf " REF TLL TEJ MEM\n"
	for (( i = 1; i <= $contador; i++ )); do
			printf " ${ordenado_arr_colores[$i]}%-*s %-*s %-*s %-*s $DEFAULT\n" 3 ${ordenado_nombres_procesos[$i]} 3 ${ordenado_arr_tiempos_llegada[$i]} 3 ${ordenado_arr_tiempos_ejecucion[$i]} 3 ${ordenado_arr_memoria[$i]}
	done
	read -ers -p "Pulse [intro] para continuar la ejecucion"
}

function entrada_por_teclado {
	op="s"
	contador=1
	echo "Introduce el tamaño de la memoria"
	read tamanio_memoria
	echo "El tamaño de la memoria es $tamanio_memoria"
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
			imprimir_tabla_datos
			echo "Tiempo de llegada P$contador:"
			read tiempo_llegada
			arr_tiempos_llegada[$contador]=$tiempo_llegada

			copia_inversa_arrays
			imprimir_tabla_datos
			echo "Tiempo de ejecución P$contador:"
			read tiempo_ejecucion
			arr_tiempos_ejecucion[$contador]=$tiempo_ejecucion

			copia_inversa_arrays
			imprimir_tabla_datos
			echo "Memoria P$contador:"
			read memoria
			arr_memoria[$contador]=$memoria

			ordenar_arrays_por_Tll
			copiar_arrays

			#echo "${arr_tiempos_llegada[@]}"
			#echo "${arr_tiempos_ejecucion[@]}"
			#echo "${arr_memoria[@]}"
			#echo "${nombres_procesos[@]}"
			#echo "${arr_colores[@]}"

			imprimir_tabla_datos
			pregunto_si_otro_proceso_mas

			if [ "$op" == "s" ]; then
				contador=$(($contador+1))
			fi
	done
}

function entrada_aleatoria {
	tamanio_memoria=$((RANDOM%99))
	echo "El tamaño de la memoria es $tamanio_memoria"
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

function corte_datos {
	cd FICHEROS_ENTRADA
	tamanio_memoria=`sed -n 1p $fichero_entrada | cut -d ":" -f 2`
	echo "El tamaño de la memoria es $tamanio_memoria"

	for (( contador = 1; contador <= $(($procesos_en_fichero+2)); contador++ )); do
			arr_tiempos_llegada[$contador]=`sed -n $(($contador+2))p $fichero_entrada | cut -d ":" -f 1`
			arr_tiempos_ejecucion[$contador]=`sed -n $(($contador+2))p $fichero_entrada | cut -d ":" -f 2`
			arr_memoria[$contador]=`sed -n $(($contador+2))p $fichero_entrada | cut -d ":" -f 3`
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

function entrada_por_fichero {
	echo "Ficheros en el directorio FICHEROS_ENTRADA"
	cd FICHEROS_ENTRADA
	ls
	cd ../
	echo "Escribe el fichero del que deseas extraer los datos:"
	read fichero_entrada
	procesos_en_fichero=(`wc -l ./FICHEROS_ENTRADA/$fichero_entrada`)
	procesos_en_fichero=$(($procesos_en_fichero-1))
	echo "El numero de líneas del fichero es $procesos_en_fichero"
	contador=$procesos_en_fichero
	corte_datos
}

function menu_entrada {

	echo "Elige una de las opciones para introducir los datos:"
	echo "1-> Entrada por teclado"
	echo "2-> Generar datos aleatorios"
	echo "3-> Leer desde un archivo"
	read opcion_menu_datos
	case $opcion_menu_datos in
		1)
			echo "Has elegido entrada por teclado:"
			entrada_por_teclado
			
		;;

		2)
			echo "Has elegido generar los datos aleatoriamente:"
			entrada_aleatoria
			
		;;

		3)
			echo "Has elegido lectura desde archivo:"
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
			echo "ERROR"
		;;
	esac
}

function inicializar_array_memoria {
	for (( i = 0 ; i <=$tamanio_memoria ; i++ )); do
		array_memoria[$i]=0
	done
}

function inicializar_array_tiempo_restante {
	array_tiempo_restante[0]=10000
	for (( i = 1 ; i <= $contador ; i++ )); do
		array_tiempo_restante[$i]="-"
	done
}

function inicializar_array_tiempo_espera {
	for (( i = 1 ; i <= $contador ; i++ )); do
		array_tiempo_espera[$i]="-"
	done
}

function inicializar_array_tiempo_retorno {
	for (( i = 1 ; i <= $contador ; i++ )); do
		array_tiempo_retorno[$i]="-"
	done
}

function inicializar_array_estado {
	for (( i = 1 ; i <= $contador ; i++ )); do
		array_estado[$i]="Fuera del sistema"
	done
}

function imprimir_tabla {
	printf " REF TLL TEJ MEM | TES TRT TRE ESTADO\n"
	for (( i = 1; i <= $contador; i++ )); do
		printf " ${ordenado_arr_colores[$i]}%-*s %-*s %-*s %-*s $DEFAULT|${ordenado_arr_colores[$i]} %-*s %-*s %-*s %-*s $DEFAULT\n" 3 "${ordenado_nombres_procesos[$i]}" 3 "${ordenado_arr_tiempos_llegada[$i]}" 3 "${ordenado_arr_tiempos_ejecucion[$i]}" 3 "${ordenado_arr_memoria[$i]}" 3 "${array_tiempo_espera[$i]}" 3 "${array_tiempo_retorno[$i]}" 3 "${array_tiempo_restante[$i]}" 3 "${array_estado[$i]}"
	done

}

function anadirCola {
	((tamCola++))
	cola[$tamCola]=$proceso
	array_estado[$proceso]="En espera"
	array_tiempo_espera[$proceso]=0
	array_tiempo_retorno[$proceso]=0
}

function eliminarCola {
	local -i i
	for(( i = 1; i <= tamCola; i++ )); do
		cola[$i]=${cola[$i+1]}
	done
    ((tamCola--))
}

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
	array_estado[$proceso_a_meter_en_memoria]="En memoria"
}

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

function calcular_memoria_restante {
	memoria_restante=0
	for (( i = 1; i <= $tamanio_memoria ; i++ )); do
		if [[ ${array_memoria[$i]} -eq 0 ]]; then
			((memoria_restante++))
		fi
	done
}

function imprimir_mem {
	#echo MEMORIA
	for (( i = 1; i <=$tamanio_memoria ; i++ )); do
		echo -n "${array_memoria[$i]}"
	done
	echo ""
}

function imprimir_linea_temporal {
	for (( i = 0; i <= $tiempo; i++ )); do
		printf "${ordenado_arr_colores[${array_linea_temporal[$i]}]}\u2593$DEFAULT"
	done
	echo ""
}

function imprimir_linea_memoria {
	for (( i = 1; i <= $tamanio_memoria; i++ )); do
		printf "${ordenado_arr_colores[${array_memoria[$i]}]}\u2593$DEFAULT"
	done
	echo ""
	read -ers -p "Pulse [intro] para continuar la ejecucion"
	echo ""
}

#Esta funcion calcula todos los elementos en el script
function bucle_principal_script {

	declare -a cola
	declare -a array_estado
	declare -a array_tiempo_restante
	declare -a array_tiempo_espera
	declare -a array_tiempo_retorno
	declare -a array_linea_temporal
	declare -a array_memoria

	proceso=1
	tamCola=0
	proceso_en_ejecucion=0
	tiempo=0
	procesos_ejecutados=0

	inicializar_array_tiempo_espera
	inicializar_array_tiempo_restante
	inicializar_array_estado
	inicializar_array_tiempo_retorno
	inicializar_array_memoria

	while [[ $procesos_ejecutados -lt $contador ]]; do
		cambio_a_imprimir=0
		#echo Tiempo=$tiempo

		if [[ $proceso_en_ejecucion -ne 0 ]] && [[ $tiempo -ne 0 ]]; then
			array_tiempo_restante[$proceso_en_ejecucion]=$((${array_tiempo_restante[$proceso_en_ejecucion]}-1))
		fi

		if [[ ${array_tiempo_restante[$proceso_en_ejecucion]} -eq 0 ]]; then
			if [[ $proceso_en_ejecucion -ne 0 ]]; then
				#echo $proceso_en_ejecucion
				((procesos_ejecutados++))
			fi
			array_estado[$proceso_en_ejecucion]="Finalizado"
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
				array_tiempo_restante[$proceso_en_ejecucion]=${ordenado_arr_tiempos_ejecucion[$proceso_en_ejecucion]}
				array_estado[$proceso_en_ejecucion]="En ejecucion"
				cambio_a_imprimir=1

		fi

		#Con esto actualizo unidad de tiempo a unidad de tiempo la LINEA TEMPORAL
		array_linea_temporal[$tiempo]=$proceso_en_ejecucion

		#Bucle encargado de calcular el TIEMPO EN ESPERA
		for (( i = 1; i <= $contador ; i++ )); do
			if [[ ${array_estado[$i]} == "En memoria" ]] || [[ ${array_estado[$i]} == "En espera" ]]; then
				if [[ $tiempo -ne ${ordenado_arr_tiempos_llegada[$i]} ]]; then
					array_tiempo_espera[$i]=$((${array_tiempo_espera[$i]}+1))
				fi
			fi
		done

			#Bucle encargado de calcular el TIEMPO DE RETORNO
		for (( i = 1; i <= $contador ; i++ )); do
			if [[ ${array_estado[$i]} == "En memoria" ]] || [[ ${array_estado[$i]} == "En espera" ]] || [[ ${array_estado[$i]} == "En ejecucion" ]] || [[ ${array_estado[$i]} == "Finalizado" &&  ${ordenado_arr_tiempos_ejecucion[$i]} -eq $tiempo ]]; then
				if [[ $tiempo -ne ${ordenado_arr_tiempos_llegada[$i]} ]]; then
					array_tiempo_retorno[$i]=$((${array_tiempo_retorno[$i]}+1))
				fi
			fi
		done
		
		#echo Tiempo=$tiempo
		#echo Cola:
		#echo ${cola[@]}
		#echo "P_EN_EJ:${proceso_en_ejecucion}"
		#echo "P_EJECUTADOS:${procesos_ejecutados}"
		#echo "Tamanio memoria: $tamanio_memoria"
		#echo Linea Temporal:
		#echo ${array_linea_temporal[@]}

		if [[ $cambio_a_imprimir -eq 1 ]]; then
			clear
			echo Tiempo=$tiempo
			echo ""
			imprimir_tabla
			echo ""
			echo "LINEA TEMPORAL:"
			imprimir_linea_temporal
			echo ""
			echo "LINEA MEMORIA:"
			#echo "${#array_memoria[@]}"
			#echo "${array_memoria[@]}"
			#imprimir_mem
			echo "Tamaño memoria = $tamanio_memoria"
			imprimir_linea_memoria 

		fi
		#echo Memoria:
		
		

		((tiempo++))
	done

	#imprimir_tabla
	#echo ${cola[@]}
	#echo ${array_estado[@]}

	# commit de prueba
}

function quitar_clear {
	sed -i 's/\x1b\[3J//g' informeColor.txt
	sed -i 's/\x1b\[2J//g' informeColor.txt
	sed -i 's/\x1b\[H//g' informeColor.txt
	#sed -i 's/\x1b\[3J\x1b\[2J\x1b\[H//g' informePrueba.txt no va
}

function pasar_fichero_a_BN {
	sed -r "s/\x1B\[(([0-9]{1,2})?(;)?([0-9]{1,2})?)?[m,K,H,f,J]//g" informeColor.txt > informeBN.txt
}

#Esta funcion es la encargada de llamar a la entrada, al bucle principal y a los informes/salida
function principal {
	rm informeColor.txt
	rm informeBN.txt
	menu_entrada
	imprimir_tabla_datos
	bucle_principal_script | tee informeColor.txt
	quitar_clear
	pasar_fichero_a_BN	
}

principal