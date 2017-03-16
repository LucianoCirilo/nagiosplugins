#!/bin/bash

#################################################################################
###										#
### Verificando Modems e Placa E1 logam saida ON para Alarmes de Erro		#
### By Luciano Cirilo - lucianosuper at hotmail.com				#
###										#
#################################################################################

## executa o comando
asterisk -r -x 'khomp links errors show' > /tmp/khomp.log


cat /tmp/khomp.log | grep -i "Lost" > /dev/null
result1=$?

cat /tmp/khomp.log | grep -i "alarm" > /dev/null
result2=$?

cat /tmp/khomp.log | grep -v "Khomp Errors Counters on Links" | grep -i "error" > /dev/null
result3=$?



if [ "$result1" -eq 0 -o "$result2" -eq 0 -o "$result3" -eq 0 ]
then
	echo -e "CRITICAL - Canais GSM/Celular Apresentando Erro"
	exit 2
else
        echo -e "Os 8 Canais GSM/Celular estao OK"
       	exit 0
fi

