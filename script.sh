#!/bin/bash

# Crea una imagen nueva, que utilice bullseye-base.qcow2 como imagen base y tenga 5 GiB de tamaño máximo. Esta imagen se denominará maquina1.qcow2.
  # Comprobamos si existe la imagen base y si no la descargamos de la web: https://mega.nz/file/UvI3ETLQ#-FY372jhOTtfCvW4Mup0R9n9-XpnqtXzPnjcC3qB834

echo "⭐ Comprobando si existe la imagen base ⭐"
echo ""
sleep 2

if [ ! -f bullseye-base-sparse.qcow2 ]; then
    echo "❌ SE VA A DESCARGAR EL PAQUETE 'megatools' PARA PODER DESCARGAR LA IMAGEN BASE ❌"
    sudo apt update > /dev/null 2>&1
    sudo apt install megatools -y > /dev/null 2>&1
    echo "⭐ Descargando imagen base ⭐"
    megadl https://mega.nz/file/UvI3ETLQ#-FY372jhOTtfCvW4Mup0R9n9-XpnqtXzPnjcC3qB834
    echo "⭐ Imagen base descargada correctamente ⭐"
    echo ""
else
    echo "✅ Imagen base encontrada ✅"
    echo ""

fi

  # Creamos la imagen 

echo "⭐ Creando imagen maquina1.qcow2 ⭐"
qemu-img create -f qcow2 -b bullseye-base-sparse.qcow2 maquina1.qcow2 > /dev/null 2>&1
sleep 1
echo "------------------------------------------------------------------"
ls -la | grep maquina1.qcow2
echo "------------------------------------------------------------------"
echo ""

echo "⭐ Cambiando tamaño de la imagen a 5GB ⭐"
echo "Creando disco de datos 🐸 🐛 🐢 🐱 🐣"
qemu-img resize maquina1.qcow2 5G > /dev/null
sleep 2

echo "Creando disco de datos 🐸 🐛 🐢 🐱 🐣 🐝 🦐 🐯 "
cp maquina1.qcow2 maquina1copia.qcow2
sleep 2

echo "Creando disco de datos 🐸 🐛 🐢 🐱 🐣 🐝 🦐 🐯 🦊 🐞 🐙 🐷"
virt-resize --expand /dev/vda1 maquina1.qcow2 maquina1copia.qcow2 >/dev/null
sleep 2

echo "Creando disco de datos 🐸 🐛 🐢 🐱 🐣 🐝 🦐 🐯 🦊 🐞 🐔 🐙 🐷 🦩 🦄 🐦 🐬 🐟"
rm maquina1.qcow2 && mv maquina1copia.qcow2 maquina1.qcow2

echo "⭐ Disco de datos creado correctamente ⭐"


# Crea una red interna de nombre intra con salida al exterior mediante NAT que utilice el direccionamiento 10.10.20.0/24.

  # Comprobamos si existe la red y si no la creamos

echo "⭐ Comprobando si existe la red intra ⭐"
echo ""
sleep 2

if [ ! -f /etc/libvirt/qemu/networks/intra.xml ]; then
    echo "❌ SE VA A CREAR LA RED 'intra' ❌"
    echo ""
    echo "⭐ Creando red intra ⭐"
    virsh -c qemu:///system net-define intra.xml >/dev/null
    virsh -c qemu:///system net-start intra >/dev/null
    sleep 2
    echo "⭐ Red intra creada correctamente ⭐"

else
    echo "✅ Red intra encontrada ✅"
    echo ""

fi



