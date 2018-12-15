#!/bin/bash

#source - https://github.com/skurudo/phpmyadmin-fixer
echo "Realizando correcciones para phpmyadmin..."
sudo curl -O -k https://raw.githubusercontent.com/skurudo/phpmyadmin-fixer/master/pma-ubuntu.sh && sudo chmod +x pma-ubuntu.sh && sudo ./pma-ubuntu.sh

echo "Realizando correccion para webmail"
if [ -f /etc/dovecot/conf.d/15-mailboxes.conf ]; then
    echo "Renombrando fichero y reiniciando servicio..."
	sudo mv /etc/dovecot/conf.d/15-mailboxes.conf /etc/dovecot/conf.d/15-mailboxes.conf.bak
	sudo service dovecot restart
else
	echo "El fichero no existe o ha sido renombrado"
fi
