# Criado em: 2011/05/07 (Sáb) 11:43:57 (BRT)
# Autor: Rafael Dutra <raffaeldutra@gmail.com>
# http://www.du3x.com

      prefix="/etc"
  bindPrefix="$prefix/bind"
apachePrefix="$prefix/apache2"
   aptPrefix="$prefix/apt"
     gwSenai=10.1.61.254

function checkNetwork()
{

try=1
while [ $try -ne 3 ]
do
    if [ x$(route -n | fgrep UG | awk '{print $2}') == "x" ]
    then
        clear
        echo "Nao ha um default gateway em sua maquina, tentando configurar. Tentativa $try"
        echo "Baixando a interface eth0 e reconfigurando"
        ifconfig eth0 down
	    sleep 5
        $(which dhclient) eth0
        try=$[$try+1]

        if [ $try -eq 3 ]
        then
            echo; echo "Nao foi possivel configurar uma rede para o ambiente, tente fazer manualmente"
			echo "Verifique tambem se sua placa de rede (caso use VMware, Virtual Box ... ) se"
			echo "a placa esta em modo bridge"; echo
            exit 1
        fi
	else
		echo; echo "Gateway OK, prosseguindo"
	    sleep 5
		try=3
    fi
done

}

# funcao que gera as interfaces virtuais com uma faixa de ip
# gerada randomicamente
function setAliasForNic()
{

clear
cat << EOT

Configurando interfaces virtuais
EOT

sleep 2

 nic=eth0
mask="255.255.255.0"

rede=$(($RANDOM/130))
  ip=$(($RANDOM/140))

t=$(echo 172.16.$rede.$ip | cut -d . -f4)
c=1
while [ $c -ne 4 ]
do
    echo "ifconfig $nic:$c 172.16.$rede.$(($t + $c)) netmask $mask"; sleep 1
    ifconfig $nic:$c 172.16.$rede.$(($t + $c)) netmask $mask
    c=$[$c+1]
done

}

# funcao que retorna o arquivo /etc/resolv.conf ao seu estado normal
function setResolvconfDefaultGw()
{

echo "nameserver $(route -n | fgrep UG | awk '{print $2}')" > /etc/resolv.conf

}

# funcao que seta o nameserver de acordo com a rede virtual
function setResolvconfIV()
{

echo "nameserver $pDNetwork.1" > /etc/resolv.conf

}

# funcao (gambi) para gerar dinamicamente/randomicamente (existe a palavra ? :-) o
# mac address da placa de rede.
# se alguem tiver uma solucao melhor, aceito sugestoes
function setMacNic()
{
cat << EOT

Setado a placa para outro MAC
EOT

# down na interface
ifconfig eth0 down

# essa foi dificil :-)
ifconfig eth0 hw ether 00:$(cat <(

# valores hexadecimal
caracteres="ABCDEF1234567890"
for ((a=1; a<=5; a++))
do
    # gerando grupos de dois em dois
    for ((i=1; i<=2; i++))
    do
        echo -n "${caracteres:$[ $RANDOM % ${#caracteres} ]:1}"
    done

# para parar de imprimir o ultimo : do codigo e assim poder gerar certinho
if [ $a -ne 5 ]
then
    echo -n ":"
fi

done
)
)

}


function checkIps()
{

echo $(echo -n "$(LC_MESSAGES=C ifconfig eth0:1 | grep 'inet ' | cut -d: -f2 | cut -d " " -f1)")

}

function setEnvironment()
{

alias ll='ls -lahvFi --full-time --color=auto'
alias  l='ls -lahvFi --color=auto'

debianName=lenny

echo; echo "Configurando $aptPrefix/sources.list"

if [ $(route -n | fgrep UG | awk '{print $2}') == "$gwSenai" ]
then

cat << EOT > $aptPrefix/sources.list
deb http://apt-cache.ctai.senai.br/apt-cacher/ftp.br.debian.org/debian/ $debianName main
EOT

else
cat << EOT > $aptPrefix/sources.list
deb http://ftp.br.debian.org/debian $debianName main contrib non-free
deb-src http://ftp.br.debian.org/debian $debianName main contrib non-free
deb http://security.debian.org $debianName/updates main
deb-src http://security.debian.org $debianName/updates main
EOT
fi

echo; echo "Atualizando lista de pacotes"
sleep 3
# atualiza a lista de repositorios que foi criado acima
apt-get update

clear
echo "Instalando pacotes, seja bonzinho e espere :-P"
sleep 4
# instala os pacotes necessarios sem precisar de h?umanos para dar o yes :-P
for package in build-essential openssh-server bind9 apache2 php5 ntp ntpdate lynx dig nslookup openssl
do
	clear; echo "Instalando $package"
	sleep 2
	apt-get --force-yes -y install $package
done

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

# reinicia os servicos
function restartServices()
{

# array de servicos, caso necessario, apenas acrescentar a mais usando espaco como delimitador
servicos=(bind9 apache2 ntp nfs-common)

clear
for service in ${servicos[@]}
do
    echo; echo "Reiniciando $service"
    invoke-rc.d $service restart
	sleep 1
done

}

# verifica no decorrer da execucao do script, se todos os pacotes foram
# realmente instalados
function validateEnvironment()
{

clear; echo -n "Verificando se o pacote $1 foi instalado: "
$(which dpkg) -l $1 | grep ii >/dev/null

if [ $? -eq 0 ]
then
    echo "[ OK ]"
    sleep 2
else
    echo "[ FAIL ]"
    sleep 2
    echo "Tente instalar o pacote manualmente utilizando o seguinte comando: apt-get install $1 "
    echo "Feito isso, execute o script novamente"
    exit 1
fi

}
