#!/bin/bash
#<>
#inicializar variables

	./multiplicar_incr 0 > multiplicar_incr_serie.dat
	./multiplicar_incr 1 > multiplicar_incr_par.dat

gnuplot << END_GNUPLOT
	set title "Matrix times"
	set ylabel "Times"
	set xlabel "Matrix size"
	set key right bottom
	set grid
	set term png
	set output "matrix_times"
	plot "multiplicar_incr_serie.dat" using 1:2 with lines lw 2 title "serie", \
		"multiplicar_incr_par.dat" using 1:2 with lines lw 2 title "4 hilos bucle externo", 
	replot
	quit
END_GNUPLOT

	paste multiplicar_incr_serie.dat multiplicar_incr_par.dat > mult_incr_concat.dat
	rm -f multiplicar_incr_serie.dat 
	rm -f multiplicar_incr_par.dat

	awk '{ $3 = ""; print>"preaceleraciones.dat" }' mult_incr_concat.dat
	rm -f mult_incr_concat.dat
	awk '{$2 = $2/$3; $3 = ""; print>"aceleraciones.dat";}' preaceleraciones.dat
	rm -f preaceleraciones.dat

gnuplot << EOF
	set title "Matrix acceleration"
	set ylabel "Acceleration"
	set xlabel "Matrix size"
	set key right bottom
	set grid
	set term png
	set output "matrix_acceleration"
	plot "aceleraciones.dat" using 1:2 with lines lw 2 title "aceleraciones", 
	replot
	quit
EOF