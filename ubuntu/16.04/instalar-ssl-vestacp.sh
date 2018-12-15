#!/bin/bash

#source: https://www.mysterydata.com/how-to-configure-lets-encrypt-ssl-on-vestacp-mail-server-and-vesta-admin-centos-and-ubuntu/
#tomamos el hostname o lo lo metemos a mano
host=$(hostname)

#registramos un cron diario para actualizar el certificado ssl para nuestro dominio ppal
cat <<EOF > /etc/cron.daily/vestassl
#!/bin/bash

cert_src="/home/admin/conf/web/ssl.$host.pem"
key_src="/home/admin/conf/web/ssl.$host.key"
cert_dst="/usr/local/vesta/ssl/certificate.crt"
key_dst="/usr/local/vesta/ssl/certificate.key"

if ! cmp -s \$cert_dst \$cert_src
then
        # Copy Certificate
        cp \$cert_src \$cert_dst

        # Copy Keyfile
        cp \$key_src \$key_dst

        # Change Permission
        chown root:mail \$cert_dst
        chown root:mail \$key_dst

        # Restart Services
        service vesta restart &> /dev/null
        service exim4 restart &> /dev/null
        service dovecot restart &> /dev/null
fi
EOF

#damos permisos de ejecución
chmod +x /etc/cron.daily/vestassl

#ejecutamos
sh /etc/cron.daily/vestassl

#reiniciamos los servicios correspondiente
echo "Reiniciando vesta..."
service vesta restart
echo "Reiniciando exim4..."
service exim4 restart
echo "Reiniciando dovecot..."
service dovecot restart