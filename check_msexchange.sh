#!/bin/bash

> /tmp/exchangeresultservice.log

HOSTADDRESS="$1"

#### verifica
for i in MSExchangeADTopology MSExchangeAB MSExchangeAntispamUpdate MSExchangeEdgeSync MSExchangeFDS MSExchangeFBA MSExchangeIS MSExchangeMailSubmission MSExchangeMailboxAssistants MSExchangeMailboxReplication MSExchangeProtectedServiceHost MSExchangeRepl MSExchangeRPC MSExchangeSearch MSExchangeServiceHost MSExchangeSA MSExchangeThrottling MSExchangeTransport MSExchangeTransportLogSearch msftesql-Exchange 
do
	/usr/local/nagios/libexec/check_nt -H $HOSTADDRESS -p 1248 -v SERVICESTATE -l $i > /dev/null
	if [ $? = 0 ]
	then
		echo "nada a fazer" > /dev/null
	else
		echo "CRITICAL - O Servico $i esta Parado" >> /tmp/exchangeresultservice.log
	fi
done


#### verificando
cat /tmp/exchangeresultservice.log | grep -i Parado > /dev/null
if [ $? = 0 ]
then
	cat /tmp/exchangeresultservice.log
	exit 2
else
	echo "Todos os Servicos MS_Exchange_Server estao OK"
	exit 0
fi
