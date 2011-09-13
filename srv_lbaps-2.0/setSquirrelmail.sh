# Criado em: 2011/08/29 (Seg) 23:14:50 (BRT)
# Ultima Modificacao: 2011/08/29 (Seg) 23:14:50 (BRT)
# Autor: Rafael Dutra <raffaeldutra@gmail.com>
# http://www.du3x.com


# setando o squirrelmail
function setSquirrelmail()
{

clear
echo "Setando configuracoes para o squirrelmail"
sleep 1
sed -i 's/localhost/'"mail.$(filterZones | head -n1)"'/g' $squirrelmailPrefix/config/config.php

}
