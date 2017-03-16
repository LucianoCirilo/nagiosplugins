#!/bin/bash

#################################################################################
###										#
### Verificando Modems e Placa E1 logam saida ON para Alarmes de Erro		#
### By Luciano Cirilo - lucianosuper at hotmail.com				#
###										#
#################################################################################

## executa o comando
/usr/sbin/asterisk -r -x 'dgv show alarms 1' > /tmp/saidacomando.log

cat /tmp/saidacomando.log | grep "|" | grep -v "-" | cut -d"|" -f2 | grep -i on > /dev/null
resultsec=$?

cat /tmp/saidacomando.log | grep "|" | grep -v "-" | cut -d"|" -f3 | grep -i on > /dev/null
resultpri=$?


if [ "$resultpri" -eq 0 ]
then
	echo -e "CRITICAL - Link Vivo 4199-63[00-99] esta com Problema Porta1"
	exit 2
elif [ "$resultsec" -eq 0 -a "$resultpri" != 0 ]
	then
		echo -e "CRITICAL - Link Vivo 4199-63[00-99] esta com Problema Porta2"
		exit 2
elif [ "$resultsec" -eq 0 -a "$resultpri" -eq 0 ]
	then
		echo -e "CRITICAL - Link Vivo 4199-63[00-99] Porta 1 e 2 esta com Problema"
		exit 2
	else
	        echo -e "Links Telefonia Vivo 4199-63[00-99] Porta 1 e 2 esta OK"
        	exit 0

fi

