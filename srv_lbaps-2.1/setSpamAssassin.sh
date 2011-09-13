# Criado em: 2011/08/23 (Ter) 20:35:40 (BRT)
# Ultima Modificacao: 2011/08/23 (Ter) 20:35:40 (BRT)
# Autor: Rafael Dutra <raffaeldutra@gmail.com>
# http://www.du3x.com

# habilitando para iniciar automaticamente
function setSpamAssassin()
{

echo "Habilitando o spamassassin"
sed -i "s/ENABLED=0/ENABLED=1/" /etc/default/spamassassin

}
