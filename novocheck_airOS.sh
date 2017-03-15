#!/bin/bash

if [ $# = 0 ]
then
echo “”
echo “./check_airOS.sh IP” 
echo “”
exit 1

fi


resultado=`(/usr/local/nagios/libexec/check_by_ssh -H "$1" -C '/usr/www/status.cgi | grep ccq | cut -d":" -f2 | cut -d "," -f1 | cut -c2-4' -l admin -t 15)`

dezena=`(echo $resultado | cut -c 1-2)`
resto=`(echo $resultado | cut -c 3-4)`

if echo $resultado | grep CRITICAL > /dev/null
then
        echo "Antena esta sem Sinal - CRITICAL"
        exit 2
elif [ $resultado -eq 100 ]
then
	echo "Qualidade do Sinal $resultado% - OK"
	exit 0
elif [ $resultado -ge 900 ]
then
	echo "Qualidade do Sinal $dezena.$resto% - OK"
	exit 0
else
	echo "Qualidade do Sinal $dezena.$resto% - CRITICAL"
	exit 2
fi

