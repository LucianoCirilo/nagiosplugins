#!/bin/sh

#########################################################################
##                                                                      #
##  check_rbl.sh - Verifica se o IP esta listado nas principais RBLs    #
##  by - Luciano Maia Cirilo - lucianosuper@hotmail.com                 #
##                                                                      #
#########################################################################

############### Funcoes ###################################
iprbl () {

        cat /tmp/$iplog | cut -d. -f 1 > /tmp/1$iplog
        cat /tmp/$iplog | cut -d. -f 2 > /tmp/2$iplog
        cat /tmp/$iplog | cut -d. -f 3 > /tmp/3$iplog
        cat /tmp/$iplog | cut -d. -f 4 > /tmp/4$iplog

paste -d"." /tmp/4$iplog /tmp/3$iplog /tmp/2$iplog /tmp/1$iplog > /tmp/reverso2$iplog.log

}

nomeip () {
	> /tmp/nslookup$iplog.log
        nslookup "$iplog" > /tmp/nslookup$iplog.log
        cat /tmp/nslookup$iplog.log | grep -v "#53" | grep "Address" | cut -c 10-900 > /tmp/$iplog
}



### Testando o Parametro - Obrigatorio digitar IP ou NOME do Host
if [ $# = 0 ]
then
   echo "Usage: $0 {IP} "
   echo "Or"
   echo "Usage: $0 200.0.0.10 "
   exit 1
fi

##### Tudo comeca aqui - usuario informa fqdn ou IP
iplog="$1"
echo "$iplog" > /tmp/$iplog


##### Zerando arquivos tmp

> /tmp/reverso2$iplog.log
> /tmp/nslookup$iplog.log
> /tmp/verifica2$iplog.log
> /tmp/saida$iplog.log
> /tmp/ips-listados2$iplog.log


#### testanto para verificar se o que o usuario digitou foi IP
grep "[0-9]\.[0-9]" /tmp/$iplog > /dev/null

if [ $? = 0 ]
then
        iprbl
else
        nomeip
        iprbl
fi

##### verificando as rbls
for i in `cat /tmp/reverso2$iplog.log`;
do
        host -t A $i.dnsbl.njabl.org >> /tmp/verifica2$iplog.log 
        host -t A $i.dul.dnsbl.sorbs.net >> /tmp/verifica2$iplog.log 
        host -t A $i.relays.mail-abuse.org >> /tmp/verifica2$iplog.log 
        host -t A $i.blackholes.mail-abuse.org >> /tmp/verifica2$iplog.log 
        host -t A $i.misc.dnsbl.sorbs.net >> /tmp/verifica2$iplog.log 
        host -t A $i.dnsbl.sorbs.net >> /tmp/verifica2$iplog.log
        host -t A $i.dialups.mail-abuse.org >> /tmp/verifica2$iplog.log 
        host -t A $i.blackholes.five-ten-sg.com >> /tmp/verifica2$iplog.log 
        host -t A $i.korea.services.net >> /tmp/verifica2$iplog.log 
        host -t A $i.b.barracudacentral.org >> /tmp/verifica2$iplog.log 
        host -t A $i.rbl.smtpcheck.net >> /tmp/verifica2$iplog.log
        host -t A $i.zen.spamhaus.org >> /tmp/verifica2$iplog.log
done

#### Tratando a Saida do Arquivo
output () {

                cat /tmp/ips-listados2$iplog.log | grep "njabl" > /dev/null
                if [ $? = 0 ]
                then
                        echo "$i.dnsbl.njabl.org" >> /tmp/saida$iplog.log
                else
                        echo "IP not found" >> /dev/null

                fi

                cat /tmp/ips-listados2$iplog.log | grep "dul.dnsbl.sorbs" > /dev/null
                if [ $? = 0 ]
                then
                        echo "$i.dul.dnsbl.sorbs.net" >> /tmp/saida$iplog.log
                else
                        echo "IP not found" >> /dev/null
                fi

                cat /tmp/ips-listados2$iplog.log | grep "relays.mail-abuse" > /dev/null
                if [ $? = 0 ]
                then
                        echo "$i.relays.mail-abuse.org" >> /tmp/saida$iplog.log
                else
                        echo "IP not found" >> /dev/null
                fi

                cat /tmp/ips-listados2$iplog.log | grep "blackholes.mail" > /dev/null
                if [ $? = 0 ]
                then
                        echo "$i.blackholes.mail-abuse.org" >> /tmp/saida$iplog.log
                else
                        echo "IP not found" >> /dev/null
                fi

                cat /tmp/ips-listados2$iplog.log | grep "misc.dnsbl.sorbs" > /dev/null
                if [ $? = 0 ]
                then
                        echo "$i.misc.dnsbl.sorbs.net" >> /tmp/saida$iplog.log
                else
                        echo "IP not found" >> /dev/null
                fi

                cat /tmp/ips-listados2$iplog.log | grep "dnsbl.sorbs.net" > /dev/null
                if [ $? = 0 ]
                then
                        echo "$i.dnsbl.sorbs.net" >> /tmp/saida$iplog.log
                else
                        echo "IP not found" >> /dev/null
                fi

                cat /tmp/ips-listados2$iplog.log | grep "dialups.mail" > /dev/null
                if [ $? = 0 ]
                then
                        echo "$i.dialups.mail-abuse.org" >> /tmp/saida$iplog.log
                else
                        echo "IP not found" >> /dev/null
                fi

                cat /tmp/ips-listados2$iplog.log | grep "blackholes.five-ten" > /dev/null
                if [ $? = 0 ]
                then
                        echo "$i.blackholes.five-ten-sg.com" >> /tmp/saida$iplog.log
                else
                        echo "IP not found" >> /dev/null
                fi

                cat /tmp/ips-listados2$iplog.log | grep "korea.services.net" > /dev/null
                if [ $? = 0 ]
                then
                        echo "$i.korea.services.net" >> /tmp/saida$iplog.log
                else
                        echo "IP not found" >> /dev/null
                fi

                cat /tmp/ips-listados2$iplog.log | grep "barracudacentral" > /dev/null
                if [ $? = 0 ]
                then
                        echo "$i.b.barracudacentral.org" >> /tmp/saida$iplog.log
                else
                        echo "IP not found" >> /dev/null
                fi

                cat /tmp/ips-listados2$iplog.log | grep "rbl.smtpcheck" > /dev/null
                if [ $? = 0 ]
                then
                        echo "$i.rbl.smtpcheck.net" >> /tmp/saida$iplog.log
                else
                        echo "IP not found" >> /dev/null
                fi

                cat /tmp/ips-listados2$iplog.log | grep "zen.spamhaus" > /dev/null
                if [ $? = 0 ]
                then
                        echo "$i.zen.spamhaus.org" >> /tmp/saida$iplog.log
                else
                        echo "IP not found" >> /dev/null
                fi
	
		echo "CRITICAL - `cat /tmp/saida$iplog.log` "
		exit 2
}

#### Entregando a resposta para o Nagios
cat /tmp/verifica2$iplog.log | grep -v "not found" | grep -v "has no A" > /tmp/ips-listados2$iplog.log
        if [ $? = 0 ]
        then
                output 
        else
                echo "OK - `cat /tmp/$iplog` IP Not List RBLs Public"
                exit 0
        fi

