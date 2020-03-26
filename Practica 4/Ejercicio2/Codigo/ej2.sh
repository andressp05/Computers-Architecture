#!/bin/bash
#<>
#inicializar variables
let Ini=40000000
let Fin=800000000
let Incr=84444444

	# if (($# != 1));then 
 #   		echo "Por favor introduce unicamente el numero de hilos con que ejecutar:"
 #    	exit 1
	# fi 

#repeticiones = 5
	
echo "ser"
	for((i = 0; i <= 9; i++));do
		for((j = 0; j < 5 ; j++));do
			let Aux=(Ini + Incr*i)
			echo "             $Aux"
			./pescalar_serie $Aux >> pescalar_serie.dat
		done;

		awk 'BEGIN{sum = 0; i = 0;} {sum += $1; i++;} END{sum = sum/i; print sum;}' pescalar_serie.dat >> pescalar_seriesum.dat
		rm -f pescalar_serie.dat
	done;
	

	paste tamanios.dat pescalar_seriesum.dat > pescalar_1.dat
	rm -f pescalar_seriesum.dat
echo "par2"
	for((i = 0; i <= 9; i++));do
		for((j = 0; j < 5 ; j++));do
			let Aux=(Ini + Incr*i)
			echo "             $Aux"
			./pescalar_par2 2 $Aux >> pescalar_par2.dat
		done;
	
		awk 'BEGIN{sum = 0; i = 0;} {sum += $1; i++;} END{sum = sum/i; print sum;}' pescalar_par2.dat >> pescalar_parsum2.dat
		rm -f pescalar_par2.dat
	done;	

	paste tamanios.dat pescalar_parsum2.dat > pescalar_2.dat
	rm -f pescalar_parsum2.dat
echo "par3"
	for((i = 0; i <= 9; i++));do
		for((j = 0; j < 5 ; j++));do
			let Aux=(Ini + Incr*i)
			echo "             $Aux"
			./pescalar_par2 3 $Aux >> pescalar_par3.dat
		done;
	
		awk 'BEGIN{sum = 0; i = 0;} {sum += $1; i++;} END{sum = sum/i; print sum;}' pescalar_par3.dat >> pescalar_parsum3.dat
		rm -f pescalar_par3.dat
	done;	

	paste tamanios.dat pescalar_parsum3.dat > pescalar_3.dat
	rm -f pescalar_parsum3.dat
echo "par4"
	for((i = 0; i <= 9; i++));do
		for((j = 0; j < 5 ; j++));do
			let Aux=(Ini + Incr*i)
			echo "             $Aux"
			./pescalar_par2 4 $Aux >> pescalar_par4.dat
		done;
	
		awk 'BEGIN{sum = 0; i = 0;} {sum += $1; i++;} END{sum = sum/i; print sum;}' pescalar_par4.dat >> pescalar_parsum4.dat
		rm -f pescalar_par4.dat
	done;	

	paste tamanios.dat pescalar_parsum4.dat > pescalar_4.dat
	rm -f pescalar_parsum4.dat
gnuplot << END
	set title "Tiempos producto escalar"
	set ylabel "Tiempos"
	set xlabel "Tamanio Vector"
	set key right bottom
	set grid
	set term png
	set output "pescalar_times.png"
	plot "pescalar_1.dat" using 1:2 with lines lw 2 title "1 hilo", \
		"pescalar_2.dat" using 1:2 with lines lw 2 title "2 hilos", \
		"pescalar_3.dat" using 1:2 with lines lw 2 title "3 hilos", \
		"pescalar_4.dat" using 1:2 with lines lw 2 title "4 hilos",
	replot
	quit
END


########ACELERACIONES###########
#Aceleraciones con 2 hilos

paste pescalar_1.dat pescalar_2.dat > preaceleracion_vector_concat2.dat
awk '{ $3 = ""; print>"preaceleracion_vector_2.dat" }' preaceleracion_vector_concat2.dat
	rm -f preaceleracion_vector_concat2.dat
	awk '{$2 = $2/$3; $3 = ""; print>"aceleraciones_vector2.dat";}' preaceleracion_vector_2.dat
	rm -f preaceleracion_vector_2.dat

#Aceleraciones con 3 hilos

paste pescalar_1.dat pescalar_3.dat > preaceleracion_vector_concat3.dat
awk '{ $3 = ""; print>"preaceleracion_vector_3.dat" }' preaceleracion_vector_concat3.dat
	rm -f preaceleracion_vector_concat3.dat
	awk '{$2 = $2/$3; $3 = ""; print>"aceleraciones_vector3.dat";}' preaceleracion_vector_3.dat
	rm -f preaceleracion_vector_3.dat

#Aceleraciones con 4 hilos

paste pescalar_1.dat pescalar_4.dat > preaceleracion_vector_concat4.dat
awk '{ $3 = ""; print>"preaceleracion_vector_4.dat" }' preaceleracion_vector_concat4.dat
	rm -f preaceleracion_vector_concat4.dat
	awk '{$2 = $2/$3; $3 = ""; print>"aceleraciones_vector4.dat";}' preaceleracion_vector_4.dat
	rm -f preaceleracion_vector_4.dat	

gnuplot << END
	set title "Aceleraciones producto escalar"
	set ylabel "Aceleraciones"
	set xlabel "Tamanio Vector"
	set key right bottom
	set grid
	set term png
	set output "pescalar_accelerations.png"
	plot "aceleraciones_vector2.dat" using 1:2 with lines lw 2 title "2 hilos", \
		"aceleraciones_vector3.dat" using 1:2 with lines lw 2 title "3 hilos", \
		"aceleraciones_vector4.dat" using 1:2 with lines lw 2 title "4 hilos",
	replot
	quit
END