#!/bin/bash

#### Tratando Falta de Informacao ##############

if [ $# = 0 ]
then
   echo ""
   echo "./check_cisco_uptime.sh [comunidade]  [IP]" 
   echo ""
   echo "Exemplo:" 
   echo "" 
   echo "./check_cisco_uptime.sh public 192.168.98.63" 
   echo ""
   exit 1
fi

comunidade="$1"
endereco="$2"

snmpget -v 1 -c "$comunidade" "$endereco" system.sysUpTime.0 > /tmp/ciscouptime$endereco 2>&1
cat /tmp/ciscouptime$endereco | grep -i sysUpTime > /dev/null
if [ $? = 0 ]
then
	echo -n "Device UP `cat /tmp/ciscouptime$endereco | cut -d")" -f2` - OK"
	exit 0
else
	echo -n "Critical ao Coletar Dados"
	exit 2
fi

