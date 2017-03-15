#!/bin/bash

##################################################################
##								##
## lucianosuper at hotmail.com					##
##								##
## Comparando arquivo base com o que esta disponivel no host	##
##								##
##################################################################



#### Tratando Falta de Informacao ##############

if [ $# = 0 ]
then
   echo ""
   echo "./check_particao_windows.sh  [IP]" 
   echo ""
   echo "Exemplo:" 
   echo "" 
   echo "./check_particao_windows.sh  192.168.98.63" 
   echo ""
   exit 1
fi

### Variavel IP
IPW="$1"


#### Teste NSCLIENT

nmap -P0 $IPW -p 1248 | grep filtered > /dev/null
bn=$?

nmap -P0 $IPW -p 1248 | grep open > /dev/null
bm=$?

if [ "$bn" -eq 0 -o "$bm" -eq 0 ]
then
        echo "Monitorar P.I.N.G" > /dev/null
else
        echo "ERRO: NSClient Nao esta funcionando."
        exit 2
fi


echo "$IPW" > /tmp/nslookup-$IPW.log



#### testanto para verificar se o que o usuario digitou foi IP
grep "[0-9]\.[0-9]" /tmp/nslookup-$IPW.log > /dev/null

if [ $? = 0 ]
then
        echo "ok" > /dev/null
else
        nslookup "$IPW" > /tmp/nslookup-$IPW.log
        IPW=(`cat /tmp/nslookup-$IPW.log | grep -v "#53" | grep "Address" | cut -c 10-900`)
fi



## Verificando se o arquivo Base Existe
if [ -e /usr/local/nagios/libexec/arqbase/$IPW-basefinal.log ]
then
	echo "OK" > /dev/null
else
	echo "CRITICAL - Arquivo Base Nao Existe ./check_arqbase.sh"
	exit 2
fi


### Verificando quantas particoes tem

> /tmp/$IPW-temp-resultado.log

for i in C D E F G H I J L M N O P Q R S T U V W X Z
do
        /usr/local/nagios/libexec/check_nt -H "$IPW" -p 1248 -v USEDDISKSPACE -l "$i" -w 50 -c 70 > /tmp/$IPW-temp-disco.log | > /dev/null
        cat /tmp/$IPW-temp-disco.log | grep -i Used > /dev/null
        if [ $? = 0 ]
        then
                echo "Monitorar Particao $i" >> /tmp/$IPW-temp-resultado.log
        else
                echo "Este Servidor Nao tem Particao" > /dev/null
        fi
done

### Se Nada Mudou Para aqui 
diff /usr/local/nagios/libexec/arqbase/$IPW-basefinal.log /tmp/$IPW-temp-resultado.log > /tmp/$IPW-baralho.log

if [ $? = 0 ]
then
	echo "OK - Todas as Particoes estao monitoradas"
	exit 0
fi

############################# Coisa de Maluco

cat /tmp/$IPW-baralho.log | rev | grep ">" 2>&1 > /dev/null
inclusao=$?
cat /tmp/$IPW-baralho.log | rev | grep "<" 2>&1 > /dev/null
alteracao=$?

resulterros=$(($inclusao + $alteracao))

####################### Se encontrar mudanca na inclusao e exclusao de particao entao cai no if abaixo
if [ "$resulterros" -eq 0 ]
then
	cat /tmp/$IPW-baralho.log | rev | grep ">" | cut -c 1 > /tmp/$IPW-baralho-inclusao.log
	cat /tmp/$IPW-baralho.log | rev | grep "<" | cut -c 1 > /tmp/$IPW-baralho-exclusao.log
	echo "CRITICAL - Ocorreu Inclusao Particao(s) `paste -s /tmp/$IPW-baralho-inclusao.log | expand -t 2 ` e Exclusao Particao(s) `paste -s /tmp/$IPW-baralho-exclusao.log | expand -t 2 ` - Gerar Novo Arquivo Base e Atualizar Cacti"
	exit 2
	elif [ "$inclusao" -eq 0 ]
	then
		cat /tmp/$IPW-baralho.log | rev | grep ">" | cut -c 1 > /tmp/$IPW-baralho-inclusao.log
		echo "CRITICAL - Ocorreu Inclusao Particao(s) `paste -s /tmp/$IPW-baralho-inclusao.log | expand -t 2 ` - Gerar Novo Arquivo Base e Atualizar Cacti"
		exit 2
	elif [ "$alteracao" -eq 0 ]
	then
		cat /tmp/$IPW-baralho.log | rev | grep "<" | cut -c 1 > /tmp/$IPW-baralho-exclusao.log
		echo "CRITICAL - Ocorreu Exclusao Particao(s) `paste -s /tmp/$IPW-baralho-exclusao.log | expand -t 2 ` - Gerar Novo Arquivo Base e Atualizar Cacti"
		exit 2
fi

