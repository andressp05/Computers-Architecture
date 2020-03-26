#!/bin/bash

#inicializamos variables
Repeticiones=5
P=0 #PM29Gr1301 (1330 mod 10 == 0)
NIni=$((256+256*$P))
P1=$((P+1))
NFin=$((256+256*P1))
NPaso=16
tam_LL=$((8*1024*1024))
fPNGcache=mult_cache.png
fPNGtime=mult_time.png

#borramos los ficheros
rm -f $fPNGcache $fPNGtime cache_1024.dat cache_2048.dat cache_4096.dat cache_8192.dat

echo "Ejecutando normal y traspuesta"

#Creamos variables y ficheros temporales para guardar los resultados temporales
for ((cache=1024;cache<=8192;cache+=cache)); do
	echo "Cache "$cache
	for ((j=0; j<Repeticiones; j++)); do
		echo "Ejecutando Repeticion "$j
		for((i=NIni; i <= NFin; i += NPaso)); do
			normalTime=$(./normal $i | awk '{print $1}');
			valgrind --tool=cachegrind --quiet --I1=$cache,1,64 --D1=$cache,1,64 --LL=$tam_LL,1,64 --cachegrind-out-file=cache$cache-normal$i.dat ./normal $i
			normalD1mr=$(cg_annotate cache$cache-normal$i.dat | head -n 18 | tail -n 1 | awk '{print $5}');
			normalD1mw=$(cg_annotate cache$cache-normal$i.dat | head -n 18 | tail -n 1 | awk '{print $8}');
			rm -f cache$cache-normal$i.dat
			traspTime=$(./traspuesta $i | awk '{print $1}');
			valgrind --tool=cachegrind --quiet --I1=$cache,1,64 --D1=$cache,1,64 --LL=$tam_LL,1,64 --cachegrind-out-file=cache$cache-trasp$i.dat ./traspuesta $i
			traspD1mr=$(cg_annotate cache$cache-trasp$i.dat | head -n 18 | tail -n 1 | awk '{print $5}');
			traspD1mw=$(cg_annotate cache$cache-trasp$i.dat | head -n 18 | tail -n 1 | awk '{print $8}');
			rm -f cache$cache-trasp$i.dat
			echo "$i $normalTime $normalD1mr $normalD1mw $traspTime $traspD1mr $traspD1mw" >> cache$cache-rep$j.dat
			sed 's/,//g' cache$cache-rep$j.dat >> CacheSwap$cache-rep$j.dat
			rm -f cache$cache-rep*
		done;
	done;

	#Guardamos los datos en un unico fichero por cache
	cat CacheSwap$cache-rep* > Total.txt
	rm -f CacheSwap$cache-rep*;
	
	#Calculamos Medias mediante tablas asociativas de awk
	echo "Calculando Medias"
	awk -v Repeticion="$Repeticiones" '
	{tiempo1[$1] += $2;}
	END {
		for (i in tiempo1) {
			print i" "tiempo1[i]/Repeticion;
		}
	} ' Total.txt | sort -nk1 > normalTime.txt

	awk -v Repeticion="$Repeticiones" '
	{normalmr[$1] += $3;}
	END {
		for (i in normalmr) {
			print i" "normalmr[i]/Repeticion;
			}
	} ' Total.txt | sort -k1 > normalD1mr.txt

	awk -v Repeticion="$Repeticiones" '
	{normalmw[$1] += $4;}
	END {
		for (i in normalmw) {
			print i" "normalmw[i]/Repeticion;
			}
	} ' Total.txt | sort -nk1 > normalD1mw.txt

	awk -v Repeticion="$Repeticiones" '
	{tiempo2[$1] += $5;}
	END {
		for (i in tiempo2) {
			print i" "tiempo2[i]/Repeticion;
		}
	} ' Total.txt | sort -nk1 > traspTime.txt

	awk -v Repeticion="$Repeticiones" '
	{traspmr[$1] += $6;}
	END {
		for (i in traspmr) {
			print i" "traspmr[i]/Repeticion;
			}
	} ' Total.txt | sort -nk1 > traspD1mr.txt

	awk -v Repeticion="$Repeticiones" '
	{traspmw[$1] += $7;}
	END {
		for (i in traspmw) {
			print i" "traspmw[i]/Repeticion;
			}
	} ' Total.txt | sort -nk1 > traspD1mw.txt

	rm -f Total.txt

	#Generamos cada fichero final por cache
	echo "Generando fichero final"
	join normalTime.txt normalD1mr.txt | join - normalD1mw.txt | join - traspTime.txt | join - traspD1mr.txt | join - traspD1mw.txt >> cache_$cache.dat
	rm normalTime.txt normalD1mr.txt normalD1mw.txt traspTime.txt traspD1mr.txt traspD1mw.txt
	done;

#Generamos las graficas
echo "Generando primera grafica"
gnuplot << END_GNUPLOT
set title "Cache Errors"
set ylabel "Errors Number"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "$fPNGcache"
plot "cache_1024.dat" using 1:3 with lines lw 2 title "Normal1024_D1MR", \
	"cache_1024.dat" using 1:4 with lines lw 2 title "Normal1024_D1MW", \
	"cache_1024.dat" using 1:6 with lines lw 2 title "Trasp1024_D1MR", \
	"cache_1024.dat" using 1:7 with lines lw 2 title "Trasp1024_D1MW", \
	"cache_2048.dat" using 1:3 with lines lw 2 title "Normal2048_D1MR", \
	"cache_2048.dat" using 1:4 with lines lw 2 title "Normal2048_D1MW", \
	"cache_2048.dat" using 1:6 with lines lw 2 title "Trasp2048_D1MR", \
	"cache_2048.dat" using 1:7 with lines lw 2 title "Trasp2048_D1MW", \
	"cache_4096.dat" using 1:3 with lines lw 2 title "Normal4096_D1MR", \
	"cache_4096.dat" using 1:4 with lines lw 2 title "Normal4096_D1MW", \
	"cache_4096.dat" using 1:6 with lines lw 2 title "Trasp4096_D1MR", \
	"cache_4096.dat" using 1:7 with lines lw 2 title "Trasp4096_D1MW", \
	"cache_8192.dat" using 1:3 with lines lw 2 title "Normal8192_D1MR", \
	"cache_8192.dat" using 1:4 with lines lw 2 title "Normal8192_D1MW", \
	"cache_8192.dat" using 1:6 with lines lw 2 title "Trasp8192_D1MR", \
	"cache_8192.dat" using 1:7 with lines lw 2 title "Trasp8192_D1MW",
replot
END_GNUPLOT

echo "Generando segunda grafica"
gnuplot << END_GNUPLOT
set title "Execution Time"
set ylabel "Execution Time (s)"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "$fPNGtime"
plot "cache_1024.dat" using 1:2 with lines lw 2 title "Normal1024", \
	"cache_1024.dat" using 1:5 with lines lw 2 title "Trasp1024", \
	"cache_2048.dat" using 1:2 with lines lw 2 title "Normal2048", \
	"cache_2048.dat" using 1:5 with lines lw 2 title "Trasp2048", \
	"cache_4096.dat" using 1:2 with lines lw 2 title "Normal4096", \
	"cache_4096.dat" using 1:5 with lines lw 2 title "Trasp4096", \
	"cache_8192.dat" using 1:2 with lines lw 2 title "Normal8192", \
	"cache_8192.dat" using 1:5 with lines lw 2 title "Trasp8192",
replot
quit
END_GNUPLOT

echo "Generando graficas auxiliares"
gnuplot << END_GNUPLOT
set title "Cache Errors"
set ylabel "Errors Number"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "read-errors.png"
plot "cache_1024.dat" using 1:3 with lines lw 2 title "Normal1024_D1MR", \
	"cache_1024.dat" using 1:6 with lines lw 2 title "Trasp1024_D1MR", \
	"cache_2048.dat" using 1:3 with lines lw 2 title "Normal2048_D1MR", \
	"cache_2048.dat" using 1:6 with lines lw 2 title "Trasp2048_D1MR", \
	"cache_4096.dat" using 1:3 with lines lw 2 title "Normal4096_D1MR", \
	"cache_4096.dat" using 1:6 with lines lw 2 title "Trasp4096_D1MR", \
	"cache_8192.dat" using 1:3 with lines lw 2 title "Normal8192_D1MR", \
	"cache_8192.dat" using 1:6 with lines lw 2 title "Trasp8192_D1MR", 
replot
quit
END_GNUPLOT

gnuplot << END_GNUPLOT
set title "Cache Errors"
set ylabel "Errors Number"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "write-errors.png"
plot "cache_1024.dat" using 1:4 with lines lw 2 title "Normal1024_D1MW", \
	"cache_1024.dat" using 1:7 with lines lw 2 title "Trasp1024_D1MW", \
	"cache_2048.dat" using 1:4 with lines lw 2 title "Normal2048_D1MW", \
	"cache_2048.dat" using 1:7 with lines lw 2 title "Trasp2048_D1MW", \
	"cache_4096.dat" using 1:4 with lines lw 2 title "Normal4096_D1MW", \
	"cache_4096.dat" using 1:7 with lines lw 2 title "Trasp4096_D1MW", \
	"cache_8192.dat" using 1:4 with lines lw 2 title "Normal8192_D1MW", \
	"cache_8192.dat" using 1:7 with lines lw 2 title "Trasp8192_D1MW",
replot
END_GNUPLOT

echo "Fin de la ejecucion del script"