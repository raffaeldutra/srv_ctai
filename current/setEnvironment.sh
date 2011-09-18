# Criado em: 2011/05/07 (Sáb) 11:43:57 (BRT)
# Autor: Rafael Dutra <raffaeldutra@gmail.com>
# http://www.du3x.com

            prefix="/etc"
        bindPrefix="$prefix/bind"
      apachePrefix="$prefix/apache2"
     postfixPrefix="$prefix/postfix"
      amavisPrefix="$prefix/amavis"
      clamavPrefix="$prefix/clamav"
squirrelmailPrefix="/usr/share/squirrelmail"
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
echo "Configurando interfaces virtuais"

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

# funcao que seta o nameserver de acordo com a rede virtual
function setResolvconf()
{

echo "nameserver $(checkIps eth0)" > /etc/resolv.conf

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

# para parar de imprimir o ultimo : do codigo e assim poder gerar certinho, gambiarra, mas ..
if [ $a -ne 5 ]
then
    echo -n ":"
fi

done
)
)

}

# retorna ip das placas de rede
# se foi setado parametro, utiliza virtual, senao, pega o que foi passado
function checkIps()
{

if [ "x$1" == "x" ]
then
    nic=eth0:1
else
    nic=$1
fi

echo $(echo -n "$(LC_MESSAGES=C ifconfig $nic | grep 'inet ' | cut -d: -f2 | cut -d " " -f1)")

}

function setEnvironment()
{

# qual a versao que esta sendo usada ?
if [ "$(cat /etc/debian_version | cut -d . -f1 )" -eq 6 ]
then
    debianName=squeeze
elif [ "$(cat /etc/debian_version | cut -d . -f1 )" -eq 5 ]
    debianName=lenny
elif [ "$(cat /etc/debian_version | cut -d . -f1 )" -eq 4 ]
    debianName=etch
else
    echo "Versao de sistemas desconhecida, saindo"
    exit 1
fi

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
sleep 5


if [ "$1" == "-abei" ]
then

# instala os pacotes necessarios sem precisar de h?umanos para dar o yes :-P
package=(openssh-server bind9 apache2 lynx nslookup postifx courier-base courier-imap qpopper amavisd-new arj cabextract cpio lzop
ripole spamassassin spamc razor dcc-client gpm squirrelmail pyzor postfix clamav clamav-docs clamav-daemon
clamav-freshclam clamav-testfiles arc arj bzip2 cabextract nomarch p7zip pax tnef unzip zoo lha unrar vim)

else
do
package=(openssh-server bind9 apache2 php5 ntp ntpdate lynx dig nslookup openssl vsftpd nfs-kernel-server nfs-common
postifx courier-base courier-imap courier-pop qpopper gpm postfix vim icedove)
done

clear; echo "Instalando ${package[@]}"
sleep 2
DEBIAN_FRONTEND=noninteractive apt-get --force-yes -y install ${package[@]}

fi
}

# reinicia os servicos.
# $1 = funcao que diz qual opcao de configuracao foi escolhido
function restartServices()
{

# verificacao para saber qual opcao esta sendo chamada, pois dependendo do tipo, sao reiniciados
# especificos tipos de servicos
if [ "$1" == "-abei" ]
then
    # array de servicos, caso necessario, apenas acrescentar a mais usando espaco como delimitador
    servicos=(bind9 postfix courier-imap apache2 amavis clamav-freshclam)
else
    # array de servicos, caso necessario, apenas acrescentar a mais usando espaco como delimitador
    servicos=(bind9 apache2 ntp nfs-common vsftpd)
fi

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
    echo "Tentando instalar $1 novamente"
    DEBIAN_FRONTEND=noninteractive apt-get --force-yes -y install $1

    echo; echo -n "Verificando se o pacote $1 foi instalado: "
    $(which dpkg) -l $1 | grep ii >/dev/null
    if [ $? -eq 0 ]
    then
        echo "[ OK ]"
    else
        echo "[ FAIL ]"
        echo "Tente instalar o pacote manualmente utilizando o seguinte comando: apt-get install $1 "
        echo "Feito isso, execute o script novamente"
        exit 1
    fi
fi

}

function setBashrc()
{

cat << EOT >> /root/.bashrc
alias    l="ls -lahFi --color=auto"
alias   df="df -h"
alias free="free -h"
EOT

}

function setVimrc()
{

cat << EOT >> /root/.vimrc
set guifont=Monospace\ 10
:colorscheme torte
:syntax on
EOT

}
