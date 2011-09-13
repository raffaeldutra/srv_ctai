# Criado em: 2011/05/07 (Sáb) 16:54:43 (BRT)
# Ultima Modificacao: 2011/05/07 (Sáb) 16:54:43 (BRT)
# Autor: Rafael Dutra <raffaeldutra@gmail.com>
# http://www.du3x.com

# funcao que gera os dominios alocados no apache
function setApache()
{

echo "NameVirtualHost *:443" >> $apachePrefix/apache2.conf

apacheLogDir=/var/log/apache2

cat << EOT

Configurando virtual hosts do Apache
EOT

for vHosts in $(filterZones)
do
cat <<EOT > $apachePrefix/sites-available/$vHosts
# $vHosts
<VirtualHost *:80>
	ServerAdmin webmaster@$vHosts
    ServerName www.$vHosts

	DocumentRoot /var/www/$vHosts
	<Directory /var/www/>
		Options Indexes FollowSymLinks MultiViews
		AllowOverride None
		Order allow,deny
		allow from all
	</Directory>

	ErrorLog $apacheLogDir/error.log

	# Possible values include: debug, info, notice, warn, error, crit,
	# alert, emerg.
	LogLevel warn

	CustomLog $apacheLogDir/access.log combined

</VirtualHost>

# ssl para o host $vHosts
<VirtualHost *:443>
	ServerAdmin webmaster@$vHosts
    ServerName www.$vHosts

	DocumentRoot /var/www/$vHosts
	<Directory /var/www/>
		Options Indexes FollowSymLinks MultiViews
		AllowOverride None
		Order allow,deny
		allow from all
	</Directory>

	ErrorLog $apacheLogDir/error.log

	# Possible values include: debug, info, notice, warn, error, crit,
	# alert, emerg.
	LogLevel warn

	CustomLog $apacheLogDir/access.log combined

	SSLEngine on
	SSLCertificateFile $apachePrefix/ssl/crt/$vHosts.crt
	SSLCertificateKeyFile $apachePrefix/ssl/key/$vHosts.key

</VirtualHost>
EOT

done
}


function setEnvironmentApache()
{

echo $(filterZones) | \
while read zonesAvailableApache
do
    for zonesEnabledApache in $zonesAvailableApache
    do
		ln -s $apachePrefix/sites-available/$zonesEnabledApache $apachePrefix/sites-enabled/$zonesEnabledApache
    done
done


}

function setSslForApache()
{

cat << EOT

Configurando SSL para certificados do apache
EOT

mkdir -p $apachePrefix/ssl/{key,csr,crt}

for hostSsl in $(filterZones)
do
    clear; echo "####### Responda as perguntas para gerar as chaves para $hostSsl #######"; echo
	$(which openssl) genrsa -out $apachePrefix/ssl/key/$hostSsl.key 1024
	$(which openssl) req -new -key $apachePrefix/ssl/key/$hostSsl.key -out $apachePrefix/ssl/csr/$hostSsl.csr
	$(which openssl) x509 -in $apachePrefix/ssl/csr/$hostSsl.csr -out $apachePrefix/ssl/crt/$hostSsl.crt -req -signkey $apachePrefix/ssl/key/$hostSsl.key -days 365
done

}
