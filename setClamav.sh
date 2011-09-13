# Criado em: 2011/08/24 (Qua) 00:14:50 (BRT)
# Ultima Modificacao: 2011/08/24 (Qua) 00:14:50 (BRT)
# Autor: Rafael Dutra <raffaeldutra@gmail.com>
# http://www.du3x.com

# setando o clamav
function setClamav()
{


cd /etc/skel; maildirmake Maildir 

clear
if [ $(id -u) -eq 0 ]
then
    read -p "Adicione um usuario que será usado para testes: " username
	read -s -p "Digite a senha: " password
	egrep "^$username" /etc/passwd >/dev/null
	if [ $? -eq 0 ]; then
		echo "$username ja existe meu guri/guria ! adicione um depois a mao"; sleep 4
	else
		pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
		useradd -m -p $pass $username
		[ $? -eq 0 ] && echo "Usuario $username foi adicionado, meus grandes parabens !!" || echo "Ihh meu guri, deu merda, adicione a mao mesmo!"
	fi
else
	echo "Somente com root/god pra executar esta tarefa"
fi

echo "Gerando proxy para passagem do Clamav"
sleep 2
cat << EOT >> $clamavPrefix/freshclam.conf
HTTPProxyServer proxy_edu.ctai.senai.br
HTTPProxyPort 3128
EOT

echo "Atualizando base de dados de virus"
sleep 2
$(which freshclam)


echo; echo "Gerando arquivo malicioso"
sleep 2
echo "X5O!P%@AP[4\PZX54(P^)7CC)7}\$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!\$H+H*" > /home/$username/eicar.com.txt

}

function testClamav()
{

echo; echo "Testando o clamav em /home/$username/eicar.com.txt"
sleep 5
$(which clamscan) /home/$username/eicar.com.txt

echo; echo "Testando pacote de testes fornecidos pelo clamav, iniciando em 5 segundos"
sleep 5
$(which clamdscan) /usr/share/clamav-testfiles/; sleep 10

}
