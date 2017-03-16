#!/bin/bash

###########################################
#
# Script que faz teste real do ping
# testar links de internet 
# lucianosuper at hotmail.com
#
############################################

#### Tratando Falta de Informacao ##############

if [ $# = 0 ]
then
   echo ""
   echo "./check_ping_service.sh  [FQDN]" 
   echo ""
   echo "Exemplo:" 
   echo "" 
   echo "./check_ping_service.sh  www.google.com.br" 
   echo ""
   exit 1
fi



ping -qc3 "$1" > /tmp/check-ping-service$1 2>&1 > /dev/null
a=$?
ping -qc3 "$1" >> /tmp/check-ping-service$1 2>&1 > /dev/null
b=$?
ping -qc3 "$1" >> /tmp/check-ping-service$1 2>&1 > /dev/null
c=$?

resultado=$(($a + $b + $c))

if [ "$resultado" -le 1 ]
then
	echo "Esta OK"
	exit 0
elif cat /tmp/check-ping-service$1 | grep unknown 
then
	echo "CRITICAL - Erro ao tentar Resolver Nome"
	exit 2
else
	echo "CRITICAL - Erro ao tentar pingar"
fi

