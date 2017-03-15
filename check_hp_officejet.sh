#!/bin/bash

### ZangaScripts kkkk

if [ $# = 0 ]
then
   echo "Esse Script funciona apenas para Impressora HP Officejet Pro 8600 N911a"
   echo ""
   echo "./check_hp_officejet.sh  [comunidadeSNMP]   [IPdoHost]   [Cor: black|yellow|cyan|magenta]   [ValorWarning%]    [ValorCritical%]" 
   echo ""
   echo "Exemplo:" 
   echo "" 
   echo "./check_hp_officejet.sh public 10.0.0.45 yellow 20 10" 
   echo ""
   exit 1

fi



comunidade="$1"
host="$2"
cor="$3"
warning="$4"
critical="$5"

if [ $cor == "black" ]
then
	color="1.1"
elif [ $cor == "yellow" ]
then
	 color="1.2"
elif [ $cor == "cyan" ]
then
	color="1.3"
elif [ $cor == "magenta" ]
then
        color="0.4"
else
	echo "Erro - Cor nao identificada"
fi



## Como eu descobrir qual é cada cor

#snmpwalk -v 1 -c public 10.0.0.45 -m Printer-MIB

#Printer-MIB::prtMarkerSuppliesLevel.0.1 = INTEGER: 243	x 100 / 282 = 	86%	"black ink"
#Printer-MIB::prtMarkerSuppliesLevel.0.2 = INTEGER: 81	x 100 / 110 =	73%	"yellow ink"
#Printer-MIB::prtMarkerSuppliesLevel.0.3 = INTEGER: 97	x 100 / 102 =	95%	"cyan ink"
#Printer-MIB::prtMarkerSuppliesLevel.0.4 = INTEGER: 22	x 100 / 109 =	20%	"magenta ink"

# capacidade total de cada
#snmpwalk -v 1 -c public 10.0.0.45 -m Printer-MIB prtMarkerSuppliesMaxCapacity


#### agora precisa fazer continha

## level x 100 / capacity = % do toner

if [ $cor == "black" ]
then
	BlackLevel=`snmpget -v 1 -c "$comunidade" "$host" -m Printer-MIB prtMarkerSuppliesLevel.$color | cut -d":" -f4 | cut -c 2-20`
	BlackCapacity=`snmpget -v 1 -c "$comunidade" "$host" -m Printer-MIB prtMarkerSuppliesMaxCapacity.$color | cut -d":" -f4 | cut -c 2-20`
	BlackToner=$((($BlackLevel * 100) / $BlackCapacity))
	## gt = maior
	## -a = OU
	## -le = Menor ou igual
	if [ $BlackToner -gt $warning ]
	then
		echo "Toner Preto com $BlackToner% da capacidade - OK"
		exit 0
	elif [ $BlackToner -gt $critical -a $BlackToner -le $warning ]
	then
		echo "Toner Preto com $BlackToner% da capacidade - WARNING"
		exit 1
	else
		echo "Toner Preto com $BlackToner% da capacidade - CRITICAL"
                exit 2
	fi
elif [ $cor == "yellow" ]
then
	YellowLevel=`snmpget -v 1 -c "$comunidade" "$host" -m Printer-MIB prtMarkerSuppliesLevel.$color | cut -d":" -f4 | cut -c 2-20`
	YellowCapacity=`snmpget -v 1 -c "$comunidade" "$host" -m Printer-MIB prtMarkerSuppliesMaxCapacity.$color | cut -d":" -f4 | cut -c 2-20`
	YellowToner=$((($YellowLevel * 100) / $YellowCapacity))
	if [ $YellowToner -gt $warning ]
        then
                echo "Toner Amarelo com $YellowToner% da capacidade - OK"
                exit 0
        elif [ $YellowToner -gt $critical -a $YellowToner -le $warning ]
        then
                echo "Toner Amarelo com $YellowToner% da capacidade - WARNING"
                exit 1
        else
                echo "Toner Amarelo com $YellowToner% da capacidade - CRITICAL"
                exit 2
        fi
elif [ $cor == "cyan" ]
then
	CyanLevel=`snmpget -v 1 -c "$comunidade" "$host" -m Printer-MIB prtMarkerSuppliesLevel.$color | cut -d":" -f4 | cut -c 2-20`
	CyanCapacity=`snmpget -v 1 -c "$comunidade" "$host" -m Printer-MIB prtMarkerSuppliesMaxCapacity.$color | cut -d":" -f4 | cut -c 2-20`
	CyanToner=$((($CyanLevel * 100) / $CyanCapacity))
	if [ $CyanToner -gt $warning ]
        then
                echo "Toner Ciano com $CyanToner% da capacidade - OK"
                exit 0
        elif [ $CyanToner -gt $critical -a $CyanToner -le $warning ]
        then
                echo "Toner Ciano com $CyanToner% da capacidade - WARNING"
                exit 1
        else
                echo "Toner Ciano com $CyanToner% da capacidade - CRITICAL"
                exit 2
        fi
elif [ $cor == "magenta" ]
then
	MagentaLevel=`snmpwalk -v 1 -c $comunidade $host -m Printer-MIB prtMarkerSuppliesLevel | grep prtMarkerSuppliesLevel.$color | cut -d":" -f4 | cut -c 2-20`
	MagentaCapacity=`snmpwalk -v 1 -c $comunidade $host -m Printer-MIB prtMarkerSuppliesMaxCapacity | grep prtMarkerSuppliesMaxCapacity.$color | cut -d":" -f4 | cut -c 2-20`
        MagentaToner=$((($MagentaLevel * 100) / $MagentaCapacity))
if [ $MagentaToner -gt $warning ]
        then
                echo "Toner Magenta com $MagentaToner% da capacidade - OK"
                exit 0
        elif [ $MagentaToner -gt $critical -a $MagentaToner -le $warning ]
        then
                echo "Toner Magenta com $MagentaToner% da capacidade - WARNING"
                exit 1
        else
                echo "Toner Magenta com $MagentaToner% da capacidade - CRITICAL"
                exit 2
        fi
else
	echo "Erro ao coletar cor $cor"
	exit 2
fi

#echo "Capacidade $BlackCapacity, $YellowCapacity, $CyanCapacity, $MagentaCapacity"
#echo "Nivel $BlackLevel, $YellowLevel, $CyanLevel, $MagentaLevel"







