# Instalación de composer y nodejs

### Instalación de composer

Para instalar Composer tan sólo debemos de ejecutar el siguiente comando:

***\# curl -sS https://getcomposer.org/installer | php***

Una vez instalado composer, debemos de mover el ejecutable de Composer dentro de la carpeta de binarios:

***\# mv composer.phar /usr/local/bin/composer***

Le añadimos los permisos de ejecución:

***\# chmod +x /usr/local/bin/composer***

### Instalación de nodejs

Instalar curl

***\# sudo apt-get install curl***

Añadimos el repositorio de node

***\# curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -***

Instalamos nodejs

***\# sudo apt-get install nodejs***
