# Criado em: 2011/08/24 (Qua) 00:14:50 (BRT)
# Ultima Modificacao: 2011/08/24 (Qua) 00:14:50 (BRT)
# Autor: Rafael Dutra <raffaeldutra@gmail.com>
# http://www.du3x.com

# setando o clamav
function setClamav()
{

echo "Gerando proxy para passagem do Clamav"
cat << EOT >> $clamavPrefix/freshclam.conf
HTTPProxyServer proxy_edu.ctai.senai.br
HTTPProxyPort 3128
EOT

echo "Atualizando base de dados de virus"
$(which freshclam)


echo; echo "Gerando arquivo malicioso"
echo "X5O!P%@AP[4\PZX54(P^)7CC)7}\$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!\$H+H*" > /home/aluno/eicar.com.txt

}

function testClamav()
{

echo; echo "Testando o clamav em /home/aluno/eicar.com.txt"
$(which clamscan) /home/aluno/eicar.com.txt
sleep 5

echo; echo "Testando pacote de testes fornecidos pelo clamav, iniciando em 5 segundos"
sleep 5
$(which clamdscan) /usr/share/clamav-testfiles/; sleep 10

}
