#!/bin/bash

> /tmp/ListaParticao
> /tmp/particaofinal

### gerando o arquivo com as particoes validas

df -h | grep -v -E '(lock|shm|run|udev|rootfs|tmpfs)' | cut -d"%" -f2 | cut -c2-100 | grep "/" > /tmp/ListaParticao

#### para cada linha vou verificar qual e a porcentagem

for i in `cat /tmp/ListaParticao`
do
	/usr/local/nagios/libexec/check_disk -c 10% -p $i >> /tmp/particaofinal
done

### agora vou procurar particao que estiver diferente de OK


if cat /tmp/particaofinal | grep -v "DISK OK"
then
	exit 2
else
	echo "Todas as Particoes estao OK"
	exit 0
fi
