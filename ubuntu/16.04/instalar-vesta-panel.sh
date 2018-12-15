#!/bin/bash

#source - https://vestacp.com/install/
echo "Buscando y actualizando paquetes ..."
sudo apt update -y && apt upgrade -y

# Download installation script
echo "Descargando script"
sudo curl -O http://vestacp.com/pub/vst-install.sh

# Run it
echo "Iniciando instalacion"
bash vst-install.sh --lang es --force
