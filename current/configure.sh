#!/bin/bash
# Criado em: 2011/05/08 (Dom) 16:33:58 (BRT)
# Ultima Modificacao: 2011/08/24 (Qua) 23:24:06 (BRT)
# Autor: Rafael Dutra <raffaeldutra@gmail.com>
# http://www.du3x.com
#
# Distribuicao livre, apenas mantenha os creditos ;-)


function showInformations()
{

clear
cat << EOT
Executar ./configure -abei
Para reiniciar todos os servicos da integracao de email:
./configure -rs -abei

## Para enviar emails pelo squirrelmail acesse: http://mail.rafael.com.br
logue com o usuario escolhido na pergunta feita no decorrer do script
claro que mude para a sua escolha

Os arquivos como mencionado no decorrer do script, ficam localizados:
Para o bind: /etc/bind/zones e para os backups /etc/bind/zones_backup
Para o ssl do apache: /etc/apache2/ssl/dominio_que_foi_criado
Para o php: /var/www/dominio_que_foi_criado/index.php

Teste pela linha de comando as zonas: ./configure -tz
Teste pela linha de comando a zona reversa: ./configure -tzr
Teste no browser, por exemplo: http://dominio.com.br e https://dominio.com.br

Para chamar esta mensagem novamente: ./configure -si
EOT

}

# include dos arquivos
. $(pwd)/setEnvironment.sh
. $(pwd)/setBind.sh
. $(pwd)/setApache.sh
. $(pwd)/setPhp.sh
. $(pwd)/setPostfix.sh
. $(pwd)/setAmavis.sh
. $(pwd)/setSpamAssassin.sh
. $(pwd)/setSquirrelmail.sh
. $(pwd)/setClamav.sh

case "$1" in
'-ci'  )  checkIps $2                ;;
# apache, bind, php
'-abp')   setMacNic
          checkNetwork
          setBashrc
          setResolvconfDefaultGw
          setEnvironment $1
          setAliasForNic
          validateEnvironment bind9
          setBind $1
          validateEnvironment apache2
          setApache
          setModulesApache
          setEnvironmentApache
          setSslForApache
          validateEnvironment php5
          setEnvironmentApachePhp
          setResolvconfIV
          restartServices $1 # enviando a opcao selecionada
          showInformations           ;;
# apache, bind, email com integracao
'-abei' ) checkNetwork
          setResolvconfDefaultGw
          setBashrc
          setVimrc
          setEnvironment $1
          validateEnvironment bind9
          setBind $1
          validateEnvironment apache2
          setApache squirrelmail /usr/share
          setEnvironmentApache
          validateEnvironment postfix
          setPostfix
          setAmavis
          setSpamAssassin
          setSquirrelmail
          setClamav
          testClamav
          setResolvconf
          restartServices $1 # enviando a opcao selecionada
          showInformations           ;;
'-rs'   ) restartServices $2         ;;
'-bind' ) setBind                    ;;
'-fz'   ) filterZones                ;;
'-tz'   ) testZones                  ;;
'-tzr'  ) testZonesReverse           ;;
'-srs'  ) setResolvconfDefaultGw     ;;
'-si'   ) showInformations           ;;
'-srv'  ) setResolvconf              ;;
'-smn'  ) setMacNic                  ;;
'-sam'  ) setAliasForNic             ;;
'-s'    ) search $2 $3               ;;
*)
  echo "Usage: $0 [-h(help)|-f(filtering)|-c(changelog)|-d(download)|-s(search -v<optional> <software> )]"
esac
