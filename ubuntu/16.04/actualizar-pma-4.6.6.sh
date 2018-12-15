#!/bin/bash

echo "Añadiendo repositorio"
sudo add-apt-repository ppa:nijel/phpmyadmin

echo "Actualizando..."
sudo apt-get update

echo "Instalando phpmyadmin..."
sudo apt-get install phpmyadmin

# warning: La frase secreta en la configuracion (blowfish_secret) es demasiado corta.
echo "Warning(PMA): La frase secreta en la configuracion (blowfish_secret) es demasiado corta.";
echo "Generando clave...";
random=$(openssl rand -base64 32 | md5sum | awk '{print $1}')
cp /var/lib/phpmyadmin/blowfish_secret.inc.php /var/lib/phpmyadmin/blowfish_secret.inc.php.bak
echo "Clave generada: $random"

sed -i "s/\$cfg\['blowfish_secret'\]\s*=.*/\$cfg\['blowfish_secret'\] = '$random';/" /var/lib/phpmyadmin/blowfish_secret.inc.php

echo "Reinicando mysql..."
service mysql restart