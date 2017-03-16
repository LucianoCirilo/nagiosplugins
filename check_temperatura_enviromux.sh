#!/bin/sh

##################################################
##						##
##  Luciano Maia Cirilo				##
##  lucianosuper@hotmail.com 			##
## 						##
##						##	
##################################################

if [ $# = 0 ]
then
   echo ""
   echo "./check_temperatura_enviromux.sh [comunidade] [IP] [OID] [Temperatura_Warning] [Temperatura_Critical]" 
   echo ""
   echo "Exemplo:" 
   echo "" 
   echo "./check_temperatura_enviromux.sh  public  192.168.0.10 .1.3.6.1.4.1.22626.1.2.3.1.0    23   27" 
   echo ""
   exit 1
fi
### Coletando dados 
snmpget -t 5,0 -v 1 -c "$1" "$2" "$3" > /tmp/$3enviromux$2 2>&1



### tratanto erro
### caso nao encontre a palavra integer - provavel erro de conexao / firewall / equipamento indisponivel / rota e etc.
cat /tmp/$3enviromux$2 | grep -i integer > /dev/null

if [ $? = 0 ]
then
	cat /tmp/$3enviromux$2 | rev | cut -c 2-3 | rev > /tmp/$3enviromuxfinal$2
else
	echo "CRITICAL - Erro ao tentar coletar dados"
	exit 2
fi


#####

if [ `cat /tmp/$3enviromuxfinal$2` -le 10 ]
then
	echo "CRITICAL - Temperatura `cat /tmp/$3enviromuxfinal$2` Graus"
	exit 2
elif [ `cat /tmp/$3enviromuxfinal$2` -ge 26 ]
then
	echo "CRITICAL - Temperatura `cat /tmp/$3enviromuxfinal$2` Graus"
        exit 2
else
	echo "OK - Temperatura `cat /tmp/$3enviromuxfinal$2` Graus"
        exit 0
fi



