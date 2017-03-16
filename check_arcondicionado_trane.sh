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
   echo "./check_temperatura_trane.sh [comunidade] [IP] [OID] [Temperatura_Warning] [Temperatura_Critical]" 
   echo ""
   echo "Exemplo:" 
   echo "" 
   echo "./check_temperatura_trane.sh  public  .1.3.6.1.4.1.22626.1.2.3.1.0   200.9.0.10   23   27" 
   echo ""
   exit 1
fi

min=$4
max=$5

#echo $min $max

### Coletando dados 
snmpget -t 5,0 -v 1 -c "$1" "$2" "$3" > /tmp/$3temperatura$2 2>&1


### tratanto erro
### caso nao encontre a palavra integer - provavel erro de conexao / firewall / equipamento indisponivel / rota e etc.
cat /tmp/$3temperatura$2 | grep -i integer > /dev/null

if [ $? = 0 ]
then
	cat /tmp/$3temperatura$2 | rev | cut -c 1-2 | rev > /tmp/$3temperaturafinal$2
else
	echo "CRITICAL - Erro ao tentar coletar dados"
	exit 2
fi


#####

if [ `cat /tmp/$3temperaturafinal$2` -le 10 ]
then
	echo "CRITICAL - Temperatura `cat /tmp/$3temperaturafinal$2` Graus"
        exit 2
elif [ `cat /tmp/$3temperaturafinal$2` -ge 26 ]
then
	echo "CRITICAL - Temperatura `cat /tmp/$3temperaturafinal$2` Graus"
        exit 2
else
	echo "OK - Temperatura `cat /tmp/$3temperaturafinal$2` Graus"
        exit 0
fi







