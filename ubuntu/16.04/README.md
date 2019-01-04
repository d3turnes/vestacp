# Instalación limpia de vestacp en ubuntu 16.04.X LTS

### Pasos previos a la instalación

Si queremos que nuestro FQDN hostname sea accedido mediante https://midominio.com:8083 con un certificado SSL válido y no autofirmado, deberemos registrar en la zona dns de nuestro dominio (freenom, namecheap, dondominio, ...) los siguientes dos registros 

- A midominio.com ip-del-vps
- A ww<i></i>w.midominio.com ip-del-vps (opcional)

### Instalar vestacp con las opciones por default - ( PASO 1 )

- Nos conectamos al servidor via ssh, mediante el comando: ***ssh root<i></i>@your.server***
- Clonamos el repositorio
  -  \# cd /tmp
  -  \# git clone https://github.com/d3turnes/vestacp
  -  \# cd /vestacp/ubuntu/16.04/

Si lo prefiere edite el fichero para modificar las opciones por defecto

***\# bash instalar-vesta-panel.sh***

El script comienza actualizando el/los repositorio(s) y posteriormente las aplicaciones instaladas, luego mostrará un menú con el software que instalará.

- Would yo like yo continue [y/n]: ***y***
- Please enter admin email addres(direccion de email para el usaurio admin): ***miemail<i></i>@gmail.com***
- Please enter FQDN hostname [vps6xxxx.ovh.net]: ***mido<i></i>minio.com***

El proceso de instalación tomara sobre unos 15 minutos.

Una vez concluida la instalación nos habrá creado por defecto el usuario admin (con privilegios de administrador) y un sitio web (panel.midominio.com), además de enviarnos un email con las credenciales de acceso para poder entrar.

Al acceder por vez primera a https://midominio.com:8083 el sistema nos advierte que se trata de una conexión no segura, aceptamos y entramos.

### Generar un certificado válido para el FQDN - ( PASO 2 )

Iniciamos sesión como admin, ir a web(midominio.com), editar (dejar en blanco el campo alias) y marcar Soportar SSL y Soportar Lets Encrypt. Por último presionamos en guardar y ejecutamos el siguiente script desde la consola.

***\# bash instalar-ssl-vestacp.sh***

Nos salimos y volvemos a iniciar sesión, si todo ha ido bien tendremos un certificado SSL válido. Para más información [pulse aquí](https://www.mysterydata.com/how-to-configure-lets-encrypt-ssl-on-vestacp-mail-server-and-vesta-admin-centos-and-ubuntu/)

### Corregir errores de phpMyAdmin - ( PASO 3 )

Recuerde que para poder acceder a phpmyadmin es recomendable hacerlo desde https. Al intentar acceder y una vez logueado obtendremos los siguientes errores.

- El almacenamiento de configuración phpMyAdmin no está completamente configurado, algunas funcionalidades extendidas fueron deshabilitadas. 
- La conexión para controluser, como está definida en su configuración, fracasó.

Para solucionar el error, ejecute el siguiente comando desde la consola

***\# sudo curl -O -k h<i></i>ttps://raw.githubusercontent.com/skurudo/phpmyadmin-fixer/master/pma-ubuntu.sh && sudo chmod +x pma-ubuntu.sh && sudo ./pma-ubuntu.sh***

### Corregir error webmail (roundcube) - ( PASO 4 )

"Error de conexión con el servidor IMAP". Este error ocurre en ubuntu 16:04 al tratar de iniciar sesión. La solución más fiable pasa por eliminar o renombrar el fichero ***15-mailboxes.conf*** ubicado en el directorio /etc/dovecot/conf.d

***\# sudo mv /etc/dovecot/conf.d/15-mailboxes.conf /etc/dovecot/conf.d/15-mailboxes.conf.bak*** (renombramos el fichero)
***\# sudo service dovecot restart*** (reiniciamos el servicio)

Para corregir tanto los errores de mysql como los de webmail, podemos ejecutar directamente el siguiente script

***\# bash pma-fixer.sh***

Llegado a este punto tendremos en nuestro VPS instalado:

- ***PHP:***  7.0.32
- ***MySQl:*** 5.7.24
- ***PhpMyAdmin:*** 4.5.4.1

### Solución al error, Fix Exim SMTP error: Helo with invalid local IP ( PASO 5 )

Este error ocurre al intenetar enviar un email desde un cliente de correo ( thunderbird, outlook, ...) vía smtp, debido a que Exim rechaza cualquier envío procedente de una ip local.

La solución paso por desactivar dicha comprobación en el fichero exim.conf

***# cp /etc/exim/exim.conf /etc/exim/exim.conf.bak*** (realizamos una copia de seguridad)

***# nano /etc/exim/exim.conf*** (editamos el fichero)

acl_check_mail:

- deny condition = $ {if eq {$ sender_helo_name} {}}
- message = HELO required before MAIL

- drop message = Helo name contains a ip address (HELO was $ sender_helo_name) and not valid
- condition = $ {if match {$ sender_helo_name} {\ N ((\ d {1,3} [.-] \ d {1,3} [.-] \ d {1,3} [.-] \ d {1,3}) | ([0-9a-f] {8}) | ([0-9A-F] {8})) \ N} {yes} {no}}
- condition = $ {if match {$ {lookup dnsdb {>: defer_never, ptr = $ sender_host_address}} \} {$ sender_helo_name} {no} {yes}}
- delay = 45s

- drop condition = $ {if isip {$ sender_helo_name}}
- message = Access denied - Invalid HELO name (See RFC2821 4.1.3)

....
 
y lo comentamos

acl_check_mail:

- \# deny condition = $ {if eq {$ sender_helo_name} {}}
- \# message = HELO required before MAIL

- \# drop message = Helo name contains a ip address (HELO was $ sender_helo_name) and not valid
- \# condition = $ {if match {$ sender_helo_name} {\ N ((\ d {1,3} [.-] \ d {1,3} [.-] \ d {1,3} [.-] \ d {1,3}) | ([0-9a-f] {8}) | ([0-9A-F] {8})) \ N} {yes} {no}}
- \# condition = $ {if match {$ {lookup dnsdb {>: defer_never, ptr = $ sender_host_address}} \} {$ sender_helo_name} {no} {yes}}
- \# delay = 45s

- \# drop condition = $ {if isip {$ sender_helo_name}}
- \# message = Access denied - Invalid HELO name (See RFC2821 4.1.3)

...

[Para más información](http://targetveb.com/fix-exim-smtp-error-helo-invalid-local-ip.html).

***# service exim restart*** (reiniciamos exim para aplicar cambios)

---

### Actualizar a la última versión de PhpMyAdmin en ubuntu 16.04.5 LTS (Opcional) - ( PASO 6 )

Los pasos a seguir son:

- \# sudo add-apt-repository ppa:nijel/phpmyadmin
- \# sudo apt-get update
- \# sudo apt-get install phpmyadmin

Ahora nos pedirá confirmación para actualizar e instalar nuevo paquetes: [S/n]: para continuar pulsamos ***S***

A las preguntas

- Configure database for phpmyadmin with dbconfig-common? Yes
- Servidor web: Seleccionamos apache2 y Ok
- apache.conf (Y/I/N/O/D/Z) [por omision=N] ? N

Con todo esto ya tendremos actualizado phpMyAdmin a la versión 4.6.6, si volvemos a entrar nos parece un warning
"La frase secreta en la configuración (blowfish_secret) es demasiado corta."

***Solución***

- \# sudo nano /var/lib/phpmyadmin/blowfish_secret.inc.php  ( y ampliamos la cadena de 24 a 32 ó 40 caracteres.)
- \# sudo service mysql restart

Si lo prefieres puedes ejecutar directamente el script desde la consola, éste ejecutará todos los pasas anteriores y generará una clave aleatoria de 40 carcateres por nosotros.

***\# bash actualizar-pma-4.6.6.sh***

### How to solve the Error: vesta update failed

Es posible que al actualizar phpmyadmin, obtengamos un error indicando que no ha sido posible realizar las actualizaciones del sistema. Para ello ejecutamos el siguiente comando.

***\# apt update -y && apt upgrade -y***

Si al ejecutar el comando anterior obtenos un "dpkg error"

***\# dpkg --configure -a***

Ahora volvemos a lanzar las actualizaciones de vesta

***\# sudo /usr/local/vesta/bin/v-update-sys-vesta-all***

---

### Actualizando de PHP 7.0 a 7.1 ó 7.2 ( Opcional )

Antes de proceder a la instalación deberemos tener instalado el "software-properties-common", para ello ejecutamos el siguiente comando.

***\# sudo apt-get install software-properties-common python-software-properties***

***Para Apache mod_php :***

***Actualizando de PHP 7.0 a PHP 7.1:***

Añadimos Ondrejs PPA a nuestro repositorio y seguidamente hacemos un update del mismo :

***\# sudo add-apt-repository ppa:ondrej/php*** (seleccionamos la opción correspondiente)

***\# sudo apt-get update***

Si obtenemos el siguiente error "‘ascii’ codec can’t decode byte" ejecute el siguiente comando :

***\# export LANG=C.UTF-8*** y vuelva a ejcutar los comandos anteriores

***\# sudo add-apt-repository ppa:ondrej/php*** (seleccionamos la opción correspondiente)

***\# sudo apt-get update***

Instalando PHP 7.1

Añadimos o eliminamos los paquetes que necesitemos (dejen sólo los paquetes que necesiten)

***\# apt-get install libapache2-mod-php7.1 php7.1 php7.1-bcmath php7.1-bz2 php7.1-cgi php7.1-cli php7.1-common php7.1-curl php7.1-dba php7.1-dev php7.1-enchant php7.1-fpm php7.1-gd php7.1-gmp php7.1-imap php7.1-interbase php7.1-intl php7.1-json php7.1-ldap php7.1-mbstring php7.1-mcrypt php7.1-mysql php7.1-odbc php7.1-opcache php7.1-pgsql php7.1-phpdbg php7.1-pspell php7.1-readline php7.1-recode php7.1-snmp php7.1-soap php7.1-sqlite3 php7.1-sybase php7.1-tidy php7.1-xml php7.1-xmlrpc php7.1-xsl php7.1-zip***

Después de la instalación, desactivamos el módulo php 7.0 para activar el módulo recien instalado php7.1 :

***\# a2dismod php7.0*** (deshabilitamos php7.0)

***\# a2enmod php7.1*** (activamos el módulode php7.1)

Una vez activado, reinicie el servicio apache2:

***\# service apache2 restart***

Instalando PHP 7.2 ( recuerde actualizar pma a la última versión )

Añadimos o eliminamos los paquetes que necesitemos (dejen sólo los paquetes que necesiten)

***\# apt-get install libapache2-mod-php7.2 php7.2 php7.2-bcmath php7.2-bz2 php7.2-cgi php7.2-cli php7.2-common php7.2-curl php7.2-dba php7.2-dev php7.2-enchant php7.2-fpm php7.2-gd php7.2-gmp php7.2-imap php7.2-interbase php7.2-intl php7.2-json php7.2-ldap php7.2-mbstring php7.2-mysql php7.2-odbc php7.2-opcache php7.2-pgsql php7.2-phpdbg php7.2-pspell php7.2-readline php7.2-recode php7.2-snmp php7.2-soap php7.2-sqlite3 php7.2-sybase php7.2-tidy php7.2-xml php7.2-xmlrpc php7.2-xsl php7.2-zip***

Después de la instalación, desactivamos el módulo php 7.0 para activar el módulo recien instalado php7.2 :

***\# a2dismod php7.0*** (deshabilitamos php7.0)

***\# a2enmod php7.2*** (activamos el módulode php7.2)

Una vez activado, reinicie el servicio apache2:

***\# service apache2 restart***

***Extra***

Para actualizar de php7.1 a php 7.2 ejecute estos comandos:

- ***a2dismod php7.1***
- ***a2enmod php7.2***
- ***service apache2 restart***

Para volver de la versión php7.2 a php7.0 ejecute:

- ***a2dismod php7.2***
- ***a2enmod php7.0***
- ***service apache2 restart***

No olvide cambiar la terminal (cli) de php (7.2 to 7.0):

***sudo update-alternatives --set php /usr/bin/php7.0***

[Para más información](https://www.mysterydata.com/how-to-upgrade-php-7-0-to-php-7-1-or-php-7-2-on-ubuntu-vestacp/).
