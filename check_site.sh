#!/bin/bash


##################################################################
##								##
## This plugin monitor web sites using two key words		##
##								##
##                                                              ##
## lmcirilo at gmail.com                                        ##
##                                                              ##
## Monitorar se o Site esta no OK			        ##
##                                                              ##
##################################################################

if [ $# = 0 ]
then
   echo ""
   echo "./check_site.sh  [URL]   [PalavraChave1] [PalavraChave2]" 
   echo ""
   echo "Exemplo:" 
   echo "" 
   echo "./check_site.sh  www.it2b.com.br reservados Contato" 
   echo ""
   exit 1

fi

### Verificando se a Pasta existe

if [ -d /tmp/checksite/ ]
then
        echo "ok" > /dev/null
else
        mkdir /tmp/checksite
fi

/usr/bin/wget -T 8 -t 1 -nv -O - "http://$1" > /tmp/checksite/$1.log 2>&1
###
cat /tmp/checksite/$1.log | grep $2 > /dev/null
palavra1=$?
###
cat /tmp/checksite/$1.log | grep $3 > /dev/null
palavra2=$?


if [ $palavra1 = 0 -a $palavra2 = 0 ]
then
	echo -n "Site - $1 OK \n"
	exit 0
else
	echo -n "CRITICAL - Nao encontramos as palavras $2 e/ou $3 no Site $1 \n"
	exit 2
fi

