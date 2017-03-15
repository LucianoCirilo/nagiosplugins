#!/bin/bash

> /tmp/exchangeresult.log

HOSTADDRESS="$1"

#### verifica
for i in MSExchangeADTopologyService.exe MSExchangeFDS.exe MSExchangeMailSubmission.exe MSExchangeMailboxAssistants.exe MSExchangeMailboxReplication.exe msexchangerepl.exe MSExchangeThrottling.exe MSExchangeTransport.exe MSExchangeTransportLogSearch.exe
do
	/usr/local/nagios/libexec/check_nt -H $HOSTADDRESS -v PROCSTATE -d SHOWALL -l $i > /dev/null
	if [ $? = 0 ]
	then
		echo "nada a fazer" > /dev/null
	else
		echo "O processo $i esta Parado" >> /tmp/exchangeresult.log
	fi
done


#### verificando
cat /tmp/exchangeresult.log | grep -i Parado > /dev/null
if [ $? = 0 ]
then
	cat /tmp/exchangeresult.log
	exit 2
else
	echo "Todos os Processos MSExchange estao OK"
	exit 0
fi
