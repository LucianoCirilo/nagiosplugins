#!/bin/bash

##################################################################
##								##
## lucianosuper at hotmail.com					##
##								##
## Gera arquivo Base para comparacoes de Particoes Monitoradas	##
##								##
##################################################################

if [ $# = 0 ]
then
   echo ""
   echo "./check_arqbase.sh  [IP]" 
   echo ""
   echo "Exemplo:" 
   echo "" 
   echo "./check_arqbase.sh  192.168.98.63" 
   echo ""
   exit 1
fi

### Verificando se a Pasta existe

if [ -d /usr/local/nagios/libexec/arqbase ]
then
        echo "ok" > /dev/null
else
        mkdir /usr/local/nagios/libexec/arqbase
fi


### Variavel IP
IPWX="$1"

echo "$IPWX" > /tmp/nslookup-base-$IPWX.log

#### testanto para verificar se o que o usuario digitou foi IP
grep "[0-9]\.[0-9]" /tmp/nslookup-base-$IPWX.log > /dev/null

if [ $? = 0 ]
then
        echo "ok" > /dev/null
else
        nslookup "$IPWX" > /tmp/nslookup-base-$IPWX.log
        IPWX=(`cat /tmp/nslookup-base-$IPWX.log | grep -v "#53" | grep "Address" | cut -c 10-900`)
#	echo $IPWX
fi



> /usr/local/nagios/libexec/arqbase/$IPWX-basefinal.log
### Verificando quantas particoes tem
for i in C D E F G H I J L M N O P Q R S T U V W X Z
do
        /usr/local/nagios/libexec/check_nt -H "$IPWX" -p 1248 -v USEDDISKSPACE -l "$i" -w 50 -c 70 > /tmp/$IPWX-arqbase.log | > /dev/null
        cat /tmp/$IPWX-arqbase.log | grep -i Used
        if [ $? = 0 ]
        then
                echo "Monitorar Particao $i" >> /usr/local/nagios/libexec/arqbase/$IPWX-basefinal.log
        else
                echo "Este Servidor Nao tem Particao" > /dev/null
        fi
done

echo "OK - Arquivo Base Criado"
cat /usr/local/nagios/libexec/arqbase/$IPWX-basefinal.log
