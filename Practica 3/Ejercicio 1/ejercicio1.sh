#!/bin/bash

#inicializamos variables
Repeticiones=20
P=0 #PM29Gr1301 (1330 mod 10 == 0)
NIni=$((10000+1024*$P))
P1=$((P+1))
NFin=$((10000+1024*P1))
NPaso=64
fDAT=time_slow_fast.dat
fPNG=time_slow_fast.png


#borramos los ficheros
rm -f $fDAT $fPNG

#generamos fichero DAT vacío
touch $fDAT

echo "Ejecutando slow y fast"

#creamos ficheros temporales para guardar los resultados temporales
for ((j=0; j< Repeticiones; j++)); do
	echo "Ejecutando Repeticion "$j
	for ((i=NIni ; i <= NFin; i += NPaso)); do
		slowTime=$(./slow $i | head -n 2 | tail -n 1 | awk '{print $3}');
		fastTime=$(./fast $i | head -n 2 | tail -n 1 | awk '{print $3}');
		echo "$i $slowTime $fastTime" >> Ejecucion$j.txt;
	done
done

#Guardamos los datos en un unico fichero
cat Ejecucion* > Total.txt
rm -f Ejecucion*

#Comenzamos a calcular medias
echo "Calculando Medias"

#Usamos tablas asociativas de awk para slow y fast
awk -v Repeticion="$Repeticiones" '
{tiempo1[$1] += $2;}
END {
	for (i in tiempo1) {
		print i" "tiempo1[i]/Repeticion;
	}
}
' Total.txt | sort -nk1 > slow.txt
awk -v Repeticion="$Repeticiones" ' 
{tiempo2[$1] += $3;}
END {
	for (j in tiempo2) {
		print j" "tiempo2[j]/Repeticion;
	}
} ' Total.txt | sort -nk1 > fast.txt

echo "Generando fichero final"
join slow.txt fast.txt >> $fDAT 	
rm -f slow.txt fast.txt Total.txt

#Generamos la grafica
echo "Generando grafica"
gnuplot << END_GNUPLOT
set title "Slow-Fast Execution Time"
set ylabel "Execution Time (s)"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "$fPNG"
plot "$fDAT" using 1:2 with lines lw 2 title "slow", \
	"$fDAT" using 1:3 with lines lw 2 title "fast"
replot
quit
END_GNUPLOT

echo "Fin de la ejecucion del script"



    
