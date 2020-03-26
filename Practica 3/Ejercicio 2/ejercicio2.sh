#!/bin/bash

#inicializamos las variables
P=0 #PM29Gr1301 (1330 mod 10 == 0)
NIni=$((2000+1024*$P))
P1=$((P+1))
NFin=$((2000+1024*P1))
NPaso=64
tam_LL=$((8*1024*1024))
fPNGread=cache_lectura.png
fPNGwrite=cache_escritura.png

#borramos los ficheros
rm -f $fPNGread $fPNGwrite cache_1024.dat cache_2048.dat cache_4096.dat cache_8192.dat

echo "Ejecutando slow y fast"

#Creamos variables y ficheros temporales para guardar los resultados temporales
for ((cache=1024;cache<=8192;cache+=cache)); do
	echo "Cache "$cache	
	for((i=NIni; i <= NFin; i += NPaso)); do
		echo "Numero "$i
		valgrind --tool=cachegrind --quiet --I1=$cache,1,64 --D1=$cache,1,64 --LL=$tam_LL,1,64 --cachegrind-out-file=cache$cache-slow$i.dat ./slow $i
		slowD1mr=$(cg_annotate cache$cache-slow$i.dat | head -n 18 | tail -n 1 | awk '{print $5}');
		slowD1mw=$(cg_annotate cache$cache-slow$i.dat | head -n 18 | tail -n 1 | awk '{print $8}');
		rm -f cache$cache-slow$i.dat
		valgrind --tool=cachegrind --quiet --I1=$cache,1,64 --D1=$cache,1,64 --LL=$tam_LL,1,64 --cachegrind-out-file=cache$cache-fast$i.dat ./fast $i
		fastD1mr=$(cg_annotate cache$cache-fast$i.dat | head -n 18 | tail -n 1 | awk '{print $5}');
		fastD1mw=$(cg_annotate cache$cache-fast$i.dat | head -n 18 | tail -n 1 | awk '{print $8}');
		rm -f cache$cache-fast$i.dat
		echo "$i $slowD1mr $slowD1mw $fastD1mr $fastD1mw" >> cache$cache.dat 
		sed 's/,//g' cache$cache.dat >> CacheSwap$cache.dat
		rm -f cache$cache*
	done;

	#Guardamos los datos en un unico fichero por cache
	echo "Generamos fichero final"
	cat CacheSwap$cache* > cache_$cache.dat
	rm -f CacheSwap$cache*;
	done;

#Generamos las graficas
echo "Generando primera grafica"
gnuplot << END_GNUPLOT
set title "Slow-Fast Read-Errors"
set ylabel "Read-Errors Number"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "$fPNGread"
plot "cache_1024.dat" using 1:2 with lines lw 2 title "Slow1024", \
	"cache_1024.dat" using 1:4 with lines lw 2 title "Fast1024", \
	"cache_2048.dat" using 1:2 with lines lw 2 title "Slow2048", \
	"cache_2048.dat" using 1:4 with lines lw 2 title "Fast2048", \
	"cache_4096.dat" using 1:2 with lines lw 2 title "Slow4096", \
	"cache_4096.dat" using 1:4 with lines lw 2 title "Fast4096", \
	"cache_8192.dat" using 1:2 with lines lw 2 title "Slow8192", \
	"cache_8192.dat" using 1:4 with lines lw 2 title "Fast8192",
replot
END_GNUPLOT

echo "Generando segunda grafica"
gnuplot << END_GNUPLOT
set title "Slow-Fast Write-Errors"
set ylabel "Write-Errors Number"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "$fPNGwrite"
plot "cache_1024.dat" using 1:3 with lines lw 2 title "Slow1024", \
	"cache_1024.dat" using 1:5 with lines lw 2 title "Fast1024", \
	"cache_2048.dat" using 1:3 with lines lw 2 title "Slow2048", \
	"cache_2048.dat" using 1:5 with lines lw 2 title "Fast2048", \
	"cache_4096.dat" using 1:3 with lines lw 2 title "Slow4096", \
	"cache_4096.dat" using 1:5 with lines lw 2 title "Fast4096", \
	"cache_8192.dat" using 1:3 with lines lw 2 title "Slow8192", \
	"cache_8192.dat" using 1:5 with lines lw 2 title "Fast8192",
replot
quit
END_GNUPLOT

echo "Fin de la ejecucion del script"
