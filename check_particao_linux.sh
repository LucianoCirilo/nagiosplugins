#!/bin/bash

#### Tratando Falta de Informacao ##############

if [ $# -eq 0 ]
then
   echo ""
   echo "./check_particao_linux.sh  [IP] [ComunidadeSNMP] [warning] [critical] " 
   echo ""
   echo "Exemplo:" 
   echo "" 
   echo "./check_particao_linux.sh  192.168.98.63 easyIT 80 90" 
   echo ""
   exit 1
fi


## testando o diretorio
if [ -d /var/lib/centreon/centplugins ]
then
	echo "esta ok" > /dev/null
else
	echo "CRITICAL - diretorio nao encontrado /var/lib/centreon/centplugins"
	exit 2
fi


## testando o diretorio
if [ -x /usr/local/nagios/libexec/check_centreon_snmp_remote_storage ]
then
        echo "esta ok" > /dev/null
else
        echo "CRITICAL - plugin nao encontrado ou sem permissao de execucao"
        exit 2
fi



### descobrindo particoes

whoareyou="$1"

> /tmp/disco$whoareyou
> /tmp/resultdiscos$whoareyou

/usr/local/nagios/libexec/check_centreon_snmp_remote_storage -H "$whoareyou" -C "$2" -s | grep "ERROR"
varerrorinicio="$?"

if [ $varerrorinicio -eq 0 ]
then
        echo "CRITICAL - Erro ao coletar dados via SNMP-1"
        exit 2
fi


/usr/local/nagios/libexec/check_centreon_snmp_remote_storage -H "$whoareyou" -C "$2" -s | grep / | cut -d":" -f3 | cut -c2-90 > /tmp/disco$whoareyou


for i in `cat /tmp/disco$whoareyou`
do
	/usr/local/nagios/libexec/check_centreon_snmp_remote_storage -H "$whoareyou" -C "$2" -n -d $i -w "$3" -c "$4" >> /tmp/resultdiscos$whoareyou
done

##### tratando erro snmp ###################################################################################
cat /tmp/resultdiscos$whoareyou | grep "ERROR" > /dev/null
varerror="$?"

if [ $varerror -eq 0 ]
then
        echo "CRITICAL - Erro ao coletar dados via SNMP-2"
        exit 2
fi
#############################################################################################################

##### Critical 
cat /tmp/resultdiscos$whoareyou | grep -v "no output" | grep "Disk CRITICAL" > /dev/null
varresultadocritico="$?"

#### Warning 
cat /tmp/resultdiscos$whoareyou | grep -v "no output" | grep "Disk WARNING" > /dev/null
varresultadowarning="$?"


if [ $varresultadocritico -eq 0 ]
then
	cat /tmp/resultdiscos$whoareyou | grep -v "no output" | grep "Disk CRITICAL"
	exit 2
elif [ $varresultadowarning -eq 0 ]
then
	cat /tmp/resultdiscos$whoareyou | grep -v "no output" | grep "Disk WARNING"
	exit 1
else
	echo "Todas as Particoes estao OK"
	exit 0
fi
