#!/bin/bash
# Criado em: 2011/05/08 (Dom) 16:33:58 (BRT)
# Ultima Modificacao: 2011/05/08 (Dom) 16:33:58 (BRT)
# Autor: Rafael Dutra <raffaeldutra@gmail.com>
# http://www.du3x.com
#
# Distribuicao livre, apenas mantenha os creditos do autor


# roteiro
#
# setar um novo mac para as placas de rede
# verificar se o gw esta apontado para o default gw
# configurar o ambiente basico pra baixar os pacotes necessarios
#

function showInformations()
{

clear
cat << EOT
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
. $(pwd)/setApache.sh
. $(pwd)/setBind.sh
. $(pwd)/setEnvironment.sh
. $(pwd)/setPhp.sh


case "$1" in
'-ci'  ) checkIps                   ;;
'-go'  ) setMacNic
         checkNetwork
         setResolvconfDefaultGw
         setEnvironment
         setAliasForNic
         validateEnvironment bind9
         setBind
         validateEnvironment apache2
         setApache
         setEnvironmentApache
         setSslForApache
         validateEnvironment php5
         setEnvironmentApachePhp
         setResolvconfIV
         restartServices
         showInformations           ;;
'-rs'  ) restartServices            ;;
'-fz'  ) filterZones                ;;
'-tz'  ) testZones                  ;;
'-tzr' ) testZonesReverse           ;;
'-srs' ) setResolvconfDefaultGw     ;;
'-si'  ) showInformations           ;;
'-srv' ) setResolvconf              ;;
'-smn' ) setMacNic                  ;;
'-s'   ) search $2 $3               ;;
*)
  echo "Usage: $0 [-h(help)|-f(filtering)|-c(changelog)|-d(download)|-s(search -v<optional> <software> )]"
esac
