#!/bin/bash

##################################################################
##                                              		##
##  Luciano Maia Cirilo                        			##
##  lmcirilo at gmail.com                   			##
##  Script varre Windows e diz oq precisa ser monitorado        ##                        
##                                              		##      
##################################################################

#### Tratando Falta de Informacao ##############

if [ $# = 0 ]
then
   echo ""
   echo "./check_windows.sh  [IP]" 
   echo ""
   echo "Exemplo:" 
   echo "" 
   echo "./check_windows.sh  192.168.98.63" 
   echo ""
   exit 1
fi

### Variavel IP
IP="$1"

particao () {

### Testando Particoes
for i in C D E F G H I J L M N O P Q R S T U V W X Z
do
	/usr/local/nagios/libexec/check_nt -H "$IP" -p 1248 -v USEDDISKSPACE -l "$i" -w 50 -c 70 > /tmp/disco.log | > /dev/null
	cat /tmp/disco.log | grep -i Used 
	if [ $? = 0 ]
	then
		echo "Monitorar Particao $i" >> /tmp/resultadochek.log
	else
		echo "nada a fazer" > /dev/null
	fi
done	

}


processos () {

#### Testando Processos
for j in AcpMcuSvc.exe actserv.exe agntsrvc.exe AMTS.exe ApplicationServer.exe ASMCUSvc.exe bengine.exe beserver.exe BPAS.exe caseappsv.exe casmgmtsvc.exe CdfSvc.exe cdmsvc.exe clussvc.exe cmdserver.exe comserv.exe CpSvc.exe CtxActiveSync.exe ctxxmlss.exe DataMCUSvc.exe DBENG.exe  DCSServer.exe  ddesvr.exe dns.exe  encsvc.exe fb_inet_server.exe  fbserver.exe  gmssnmpmgr.exe  guisvc.exe HCAService.exe HRPrintSrv.exe HRReportSrv.exe HyperionJavaService.exe idss.exe IMAAdvanceSrv.exe ImaSrv.exe IMMcuSvc.exe inetinfo.exe jobeng.exe Kserver.exe MediationServerSvc.exe mfcom.exe monitord.exe MsDtsSrvr.exe msftesql.exe msmdsrv.exe mspadmin.exe mssearch.exe NDDigital.nBilling.nServer.Services.Logger.exe NDDigital.nBilling.nServer.Services.Manager.exe NDDigital.nBilling.nServer.Services.Server.exe NextelService.exe obsserv.exe OcsAppServerHost.exe OcsAppServerMaster.exe omtsreco.exe oracle.exe ORACLE.EXE OWSTIMER.EXE QmsAgentSvc.exe repserv.exe RMChronus.exe RMLabore.exe RMVitae.exe RTCSrv.exe SAPlpd.exe SAPOSCOL.EXE sapstartsrv.exe sgmssvc.exe sgmsvp1.exe sgmsvp2.exe skpcdsvc.exe sktsvc.exe SmaService.exe snmp.exe sqlagent90.exe sqlagent.exe SQLAGENT.EXE sqlbrowser.exe SQLSERVERAGENT sqlservr.exe sqlwriter.exe srvany.exe sserver.exe store.exe syslogd.exe tapeeng.exe tcpsvcs.exe TNSLSNR.exe TNSLSNR.EXE tomcat5.exe tomcat6.exe tomcat.exe updaterd.exe vssrvc.exe wmenc.exe
do
	/usr/local/nagios/libexec/check_nt -H "$IP" -v PROCSTATE -d SHOWALL -l "$j" > /tmp/processos.log | > /dev/null
	cat /tmp/processos.log | grep -i "not running" 
	if [ $? = 0 ]
	then
		echo "nada a fazer" > /dev/null
	else
		echo "Monitorar processo $j" >> /tmp/resultadochek.log
	fi
done

}

brincadeira () {

############# Brincando com o Tempo

echo -e "\033[1;38;5;001m .\033[0m"
echo -e "\033[1;38;5;001m ..\033[0m"
echo -e "\033[1;38;5;001m ...\033[0m"
echo -e "\033[1;38;5;001m ....\033[0m"
echo -e "\033[1;38;5;001m .....\033[0m"
echo -e "\033[1;38;5;001m ......\033[0m"
echo -e "\033[1;38;5;001m .......\033[0m"
echo -e "\033[1;38;5;001m ........\033[0m"
echo -e "\033[1;38;5;001m .........\033[0m"
echo -e "\033[1;38;5;001m ..........\033[0m"
echo -e "\033[1;38;5;001m ........... Processando...\033[0m"
echo -e "\033[1;38;5;001m ..........\033[0m"
echo -e "\033[1;38;5;001m .........\033[0m"
echo -e "\033[1;38;5;001m ........\033[0m"
echo -e "\033[1;38;5;001m .......\033[0m"
echo -e "\033[1;38;5;001m ......\033[0m"
echo -e "\033[1;38;5;001m .....\033[0m"
echo -e "\033[1;38;5;001m ....\033[0m"
echo -e "\033[1;38;5;001m ...\033[0m"
echo -e "\033[1;38;5;001m ..\033[0m"
echo -e "\033[1;38;5;001m .\033[0m"

}


final () {

echo ""
echo -e "\033[1;38;5;118mO servidor Windows esta com as seguintes portas abertas\033[0m"

nmap -sT $IP > /tmp/portas.log
nmap -sU -p 161 $IP >> /tmp/portas.log
cat /tmp/portas.log | grep open
echo ""
echo ""
echo -e "\033[1;38;5;118mO servidor Windows tem as seguintes Particoes e Processos \033[0m"

cat /tmp/resultadochek.log 
echo ""
echo ""
> /tmp/resultadochek.log

}



#### Testando Ping
ping -qc5 $IP > /dev/null
a=$?

nmap -sT $IP -p 1248 | grep open		
b=$?

if [ $a -eq 0 -a $b -eq 0 ]
then
	echo "Monitorar P.I.N.G" >> /tmp/resultadochek.log
	particao
	processos
	brincadeira
	final
else
	brincadeira
	echo ""
	echo -e "\033[1;38;5;001m#### --- ATENCAO Verificar se o IP esta Pingando ou Cliente do Nagios (NSClient - Porta 1248 TCP) Foi instalado --- ####\033[0m"
	echo ""
fi

