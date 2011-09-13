# Criado em: 2011/08/23 (Ter) 23:58:58 (BRT)
# Ultima Modificacao: 2011/08/23 (Ter) 23:58:58 (BRT)
# Autor: Rafael Dutra <raffaeldutra@gmail.com>
# http://www.du3x.com

function setAmavis()
{

echo "Alterando /etc/mailname"
sleep 2
echo "$(filterZones | head -n1)" > /etc/mailname

echo "Descomentando linhas do arquivo $amavisPrefix/conf.d/50-user"
sleep 2
# substituir na linha 13,14,24 e 25 do arquivo o # por nada, pois apenas
# queremos descomentar as linhas, foda não ? hehe, sed é o cara
sed -i '13,14s/#//' $amavisPrefix/conf.d/15-content_filter_mode
sed -i '24,25s/#//' $amavisPrefix/conf.d/15-content_filter_mode
sed -i 's/#$myhostname = "mail.example.com";/$myhostname = "mail.'"$(filterZones | head -n1)"'";/'    $amavisPrefix/conf.d/05-node_id

cat << EOT >> $amavisPrefix/conf.d/50-user

# Por default na configuração, os emails considerados spam são colocados em
# quarentena e nenhuma informação chega ao destinatário. Nesta configuração
# queremos que os emails indiquem apenas as probabilidades de serem spam,
# deixando ao utilizador a escolha das acusações a realizar. As configuração
# personalizadas sãoo guardadas no ficheiro:

\$sa_spam_subject_tag = '***SPAM*** ';
\$sa_tag_level_deflt  = undef;  # add spam info headers if at, or above that level
\$sa_tag2_level_deflt = 6.31;   # add 'spam detected' headers at that level
\$sa_kill_level_deflt = 9999;   # triggers spam evasive actions

EOT

echo "Adicionando usuario do amavis ao grupo clamav"
adduser clamav amavis
sleep 2

}
