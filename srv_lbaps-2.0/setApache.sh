# Criado em: 2011/05/07 (Sáb) 16:54:43 (BRT)
# Ultima Modificacao: 24/08/2011 Qua 22:46:32
# Autor: Rafael Dutra <raffaeldutra@gmail.com>
# http://www.du3x.com

# seta modulos do apache para ssl
function setModulesApache()
{

echo; echo "Setando os modulos de SSL para o apache"
sleep 1
# habilita ssl pelo comando a2enmod, porem se nao existir, faz a mao mesmo :-)
a2enmod ssl 2>/dev/null && enabledA2enmod=0 || enabledA2enmod=1

if [ $enabledA2enmod -ne 0 ]
then
    if [ -e $apachePrefix/mods-available/ssl.conf -a -e $apachePrefix/mods-available/ssl.load ]
    then
	    echo "ln -s $apachePrefix/mods-available/ssl.{conf,load} $apachePrefix/mods-enabled/"
	    ln -s $apachePrefix/mods-available/ssl.{conf,load} $apachePrefix/mods-enabled/
    else
        echo "Nao foi possivel achar o modulo de ssl, verifique a mao"
    fi
fi

}

# o apache na segunda versao foi feito para suportar parametros:
# $1 = nome do sistema
# $2 = caminho para o sistema
# funcao que gera os dominios alocados no apache
function setApache()
{

echo "NameVirtualHost *:443" >> $apachePrefix/apache2.conf

apacheLogDir=/var/log/apache2

cat << EOT

Configurando virtual hosts do Apache
EOT

if [ "z$1" == "z" ]
then

for vHosts in $(filterZones)
do
cat <<EOT > $apachePrefix/sites-available/$vHosts
# $vHosts
<VirtualHost *:80>
	ServerAdmin webmaster@$vHosts
    ServerName www.$1.$3

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

else
cat << EOT > $apachePrefix/sites-available/$(filterZones | head -n1)
<VirtualHost *:80>
	ServerAdmin webmaster@$(filterZones | head -n1)
    ServerName mail.$(filterZones | head -n1)

	DocumentRoot $2/$1
	<Directory $2/$1>
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
EOT

fi

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
