#!/bin/sh

> /usr/local/nagios/libexec/consulta-ms/verifica.log
> /usr/local/nagios/libexec/consulta-ms/ips-listados.log

for i in `cat /usr/local/nagios/libexec/consulta-ms/ipreverso.log`;
do
        host -t A $i.bl.spamcop.net >> /usr/local/nagios/libexec/consulta-ms/verifica.log
        host -t A $i.dnsbl.njabl.org >> /usr/local/nagios/libexec/consulta-ms/verifica.log
        host -t A $i.dul.dnsbl.sorbs.net >> /usr/local/nagios/libexec/consulta-ms/verifica.log
        host -t A $i.relays.mail-abuse.org >> /usr/local/nagios/libexec/consulta-ms/verifica.log
        host -t A $i.blackholes.mail-abuse.org >> /usr/local/nagios/libexec/consulta-ms/verifica.log
        host -t A $i.misc.dnsbl.sorbs.net >> /usr/local/nagios/libexec/consulta-ms/verifica.log
        host -t A $i.dnsbl.sorbs.net >> /usr/local/nagios/libexec/consulta-ms/verifica.log
        host -t A $i.dialups.mail-abuse.org >> /usr/local/nagios/libexec/consulta-ms/verifica.log
        host -t A $i.blackholes.five-ten-sg.com >> /usr/local/nagios/libexec/consulta-ms/verifica.log
        host -t A $i.korea.services.net >> /usr/local/nagios/libexec/consulta-ms/verifica.log
        host -t A $i.b.barracudacentral.org >> /usr/local/nagios/libexec/consulta-ms/verifica.log
        host -t A $i.rbl.smtpcheck.net >> /usr/local/nagios/libexec/consulta-ms/verifica.log
        host -t A $i.zen.spamhaus.org >> /usr/local/nagios/libexec/consulta-ms/verifica.log
done

cat /usr/local/nagios/libexec/consulta-ms/verifica.log | grep -v  "not found" | grep -v "has no A" > /usr/local/nagios/libexec/consulta-ms/ips-listados.log 
        if [ $? = 0 ]
        then
                sudo /usr/bin/mail -s "ATENCAO: Ips listados em Blacklists"  windows@computeasy.com.br < /usr/local/nagios/libexec/consulta-ms/ips-listados.log ;
		echo -n "CRITICAL - Ips listados em Blacklists"
		exit 2 
        else
                echo -n "OK - Nenhum IP listado em RBL"
		exit 0
        fi
exit
