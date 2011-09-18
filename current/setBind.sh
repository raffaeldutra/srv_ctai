# Criado em: 2011/05/07 (Sab) 13:53:57 (BRT)
# Autor: Rafael Dutra <raffaeldutra@gmail.com>
# http://www.du3x.com

# funcao que retorna apenas as zonas que foram inseridas pelo usuario, ou seja
# vai ate o arquivo named.conf.local e retorna apenas o nome das zonas
function filterZones()
{

cat $bindPrefix/named.conf.local | fgrep -w zone | sed 's/"//g;s/zone//;s/ //' | egrep '(.com|.com.br|.org|.net|.info|.tv|.br)'

}


# funcao para registrar as zonas perguntando qual o nome destas zonas
function setBind()
{

# passado via parametro para saber qual tipo de servicos configurar
if [ "$1" == "-abei" -o "x$1" == "x" ]
then
    nicForDns=$(checkIps eth0)
else
    nicForDns=$(checkIps)
fi

mkdir -p $bindPrefix/{zones,zones_backup}

echo; echo "Se houver arquivos anteriores em $bindPrefix/zones, eles serao movidos para $bindPrefix/zones_backup"
sleep 5
mv $bindPrefix/zones/* $bindPrefix/zones_backup 2>/dev/null

echo "Movendo o arquivo $bindPrefix/named.conf.local para $bindPrefix/named.conf.local.original caso exista"; echo
mv $bindPrefix/named.conf.local $bindPrefix/named.conf.local.original

# enquanto apertar enter, fica pedindo, de resto aceita tudo
tryZonesName=0
while [ $tryZonesName -eq 0 ]
do

cat << EOT

Verifique o arquivo $bindPrefix/named.conf.local.original, ele sera sempre o seu ultimo backup

Diga os nomes dessas zonas separadas por espaco
Por exemplo: rafael dutra god nazgul
EOT

echo -n "Digite o nome das zonas como mostrado acima: "
read zonesName

if [ "x$zonesName" == "x" ]
then
	echo "Digite os valores corretamente, tente novamente"
	sleep 3
else
	tryZonesName=1
fi

done

# enquanto nao for executado corretamente conforme pedido, fica em loop
right=0
while [ $right -eq 0 ]
do
    echo; echo "Digitar o nome do dominio a ser criado, sem o . inicial"
    echo "Por exemplo: com ou com.br ou net ou br ..."; echo
    echo -n "Digite o nome do dominio a ser criado, sem o . (ponto inicial) : "
    read nameDomain

# se for vazio
    if [ "x$nameDomain" == "x" ]
    then
        echo "Digitar novamente, incorreto"; echo
        sleep 3
# se comecar com ponto inicial
    elif [[ "$nameDomain" =~ ^[.] ]]
    then
        echo "Nao deve comecar com ponto conforme mostrado acima"; echo
        sleep 1
	else
# finalmente digitou certo :-P
        right=1
    fi

done

# criacao das zonas
for doCreateZone in $zonesName
do

echo "Criando os mapas da zona $doCreateZone"
sleep 1

cat << EOT >> $bindPrefix/named.conf.local
zone "$doCreateZone.$nameDomain"
{
    type master;
    file "$bindPrefix/zones/$doCreateZone.$nameDomain";
};

EOT
done

# cria o mapa para o reverso, se alguem tiver solucao melhor e menos "grande", pode ajustar
cat << EOT >> $bindPrefix/named.conf.local
zone "$(echo $(echo -n "$nicForDns." | tac -s. | cut -d . -f2-4).in-addr.arpa)"
{
    type master;
    file "$bindPrefix/zones/$doCreateZone.$nameDomain.rev";
};
EOT

# cria as entradas necessarias para o dns
for doCreateZone in $zonesName
do

echo "Criando as entradas da zona $doCreateZone"
sleep 1

cat << EOT >> $bindPrefix/zones/$doCreateZone.$nameDomain
;
; BIND data file for local loopback interface
;
\$TTL	604800
@	IN	SOA	ns.$doCreateZone.$nameDomain. root.$doCreateZone.$nameDomain. (
                $(date +%Y%m%d01)	; Serial
                604800		        ; Refresh
                86400		        ; Retry
                2419200		        ; Expire
                604800 )	        ; Negative Cache TTL
;
@	    IN	NS	ns.$doCreateZone.$nameDomain.
EOT

# aqui sao setado os subdominios do dominio, caso seja necessario mais, apenas acrescentar abaixo
    for netServices in @ ns www ftp mail ntp nfs ldap samba
    do
cat << EOT >> $bindPrefix/zones/$doCreateZone.$nameDomain
$netServices	IN  A     $nicForDns
EOT
    done
echo "@	IN  MX  5 mail.$(filterZones | head -n1)." >> $bindPrefix/zones/$doCreateZone.$nameDomain
done

# mapa reverso
cat << EOT > $bindPrefix/zones/$doCreateZone.$nameDomain.rev
;
; BIND reverse data file for local loopback interface
;
\$TTL	604800
@	IN	SOA	ns.$doCreateZone.$nameDomain. root.$doCreateZone.$nameDomain. (
            $(date +%Y%m%d01)	; Serial
			 604800		        ; Refresh
			  86400		        ; Retry
			2419200		        ; Expire
			 604800 )	        ; Negative Cache TTL
;
@	IN	NS	ns.$doCreateZone.$nameDomain.
$(echo $(echo -n "$nicForDns." | tac -s. | cut -d . -f1)) IN  PTR $doCreateZone.$nameDomain.
EOT

}

# funcao que testa as zonas criadas anteriormente usando nslookup
function testZones()
{

for zone in $(filterZones)
do
    $(which nslookup) $zone
done

}


# funcao que testa a zona reversa
function testZonesReverse()
{

$(which nslookup) $(checkIps)

}
