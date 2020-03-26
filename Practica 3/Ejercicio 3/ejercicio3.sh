#!/bin/bash

#inicializamos variables
Repeticiones=10
P=0 #PM29Gr1301 (1330 mod 10 == 0)
NIni=$((256+256*$P))
P1=$((P+1))
NFin=$((256+256*P1))
NPaso=16
tam_LL=$((8*1024*1024))
fPNGcache=mult_cache.png
fPNGtime=mult_time.png

#borramos los ficheros
rm -f $fPNGcache $fPNGtime mult.dat

echo "Ejecutando normal y traspuesta"

#Creamos variables y ficheros temporales para guardar los resultados temporales
for ((j=0; j<Repeticiones; j++)); do
	echo "Ejecutando Repeticion "$j
	for((i=NIni; i <= NFin; i += NPaso)); do
		echo "Tamanyo Matriz "$i
		normalTime=$(./normal $i | awk '{print $1}');
		valgrind --tool=cachegrind --quiet --cachegrind-out-file=normal$i.dat ./normal $i
		normalD1mr=$(cg_annotate normal$i.dat | head -n 18 | tail -n 1 | awk '{print $5}');
		normalD1mw=$(cg_annotate normal$i.dat | head -n 18 | tail -n 1 | awk '{print $8}');
		rm -f normal$i.dat
		traspTime=$(./traspuesta $i | awk '{print $1}');
		valgrind --tool=cachegrind --quiet --cachegrind-out-file=trasp$i.dat ./traspuesta $i
		traspD1mr=$(cg_annotate trasp$i.dat | head -n 18 | tail -n 1 | awk '{print $5}');
		traspD1mw=$(cg_annotate trasp$i.dat | head -n 18 | tail -n 1 | awk '{print $8}');
		rm -f trasp$i.dat
		echo "$i $normalTime $normalD1mr $normalD1mw $traspTime $traspD1mr $traspD1mw" >> rep$j.dat
		sed 's/,//g' rep$j.dat >> Rep$j.dat
		rm -f rep*
	done;
done;

#Guardamos los datos en un unico fichero
cat Rep* > Total.txt
rm -f Rep*;

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

#Generamos el fichero final pedido
echo "Generando fichero final"
join normalTime.txt normalD1mr.txt | join - normalD1mw.txt | join - traspTime.txt | join - traspD1mr.txt | join - traspD1mw.txt >> mult.dat
rm normalTime.txt normalD1mr.txt normalD1mw.txt traspTime.txt traspD1mr.txt traspD1mw.txt

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
plot "mult.dat" using 1:3 with lines lw 2 title "Normal_D1MR", \
	"mult.dat" using 1:4 with lines lw 2 title "Normal_D1MW", \
	"mult.dat" using 1:6 with lines lw 2 title "Trasp_D1MR", \
	"mult.dat" using 1:7 with lines lw 2 title "Trasp_D1MW",
replot
quit
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
plot "mult.dat" using 1:2 with lines lw 2 title "Normal", \
	"mult.dat" using 1:5 with lines lw 2 title "Trasp",
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
plot "mult.dat" using 1:3 with lines lw 2 title "Normal_D1MR", \
	"mult.dat" using 1:6 with lines lw 2 title "Trasp_D1MR",
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
plot "mult.dat" using 1:4 with lines lw 2 title "Normal_D1MW", \
	"mult.dat" using 1:7 with lines lw 2 title "Trasp_D1MW",
replot
quit
END_GNUPLOT


echo "Fin de la ejecucion del script"
