# Criado em: 2011/05/17 (Ter) 23:04:20 (BRT)
# Ultima Modificacao: 2011/05/17 (Ter) 23:05:35 (BRT)
# Autor: Rafael Dutra <raffaeldutra@gmail.com>
# http://www.du3x.com

# funcao responsavel por setar diretorios e arquivos index.php de exemplos
function setEnvironmentApachePhp()
{

echo
echo $(filterZones) | \
while read dirZonesApache
do
    for zonesInApache in $dirZonesApache
    do
        echo "Gerando arquivo /var/www/$zonesInApache/index.php"
        sleep 1.5
	    mkdir -p /var/www/$zonesInApache
        echo "<?php echo \"dominio $zonesInApache\"; ?>" > /var/www/$zonesInApache/index.php
    done
done

}
