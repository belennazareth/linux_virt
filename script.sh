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
sleep 1

# Crea una red interna de nombre intra con salida al exterior mediante NAT que utilice el direccionamiento 10.10.20.0/24.

  # Comprobamos si existe la red y si no la creamos

echo "⭐ Comprobando si existe la red intra ⭐"
echo ""
sleep 2

if [ ! -f /etc/libvirt/qemu/networks/intra.xml ]; then
    echo "❌ SE VA A CREAR LA RED 'intra' ❌"
    echo ""
    sleep 2
    
    # Comprobar si esta como root
    if [ "$EUID" -ne 0 ]
    then echo "🆘❗❗ Por favor, ejecuta el script como root ❗❗🆘"
        exit
    
    else
        echo "⭐ Creando fichero de configuración de la red intra ⭐"
        sudo echo "
            <network>
              <name>intra</name>
              <bridge name='intra'/>
              <forward/>
              <ip address='10.10.20.1' netmask='255.255.255.0'>
                <dhcp>
                  <range start='10.10.20.2' end='10.10.20.254'/>
                </dhcp>
              </ip>
            </network>
        " >> /etc/libvirt/qemu/networks/intra.xml
        echo "⭐ Fichero de configuración de la red intra creado correctamente ⭐"
        sleep 2

        echo "⭐ Creando red intra ⭐"
        virsh -c qemu:///system net-define intra.xml >/dev/null
        virsh -c qemu:///system net-autostart intra.xml >/dev/null
        sleep 2
        echo "⭐ Red intra creada correctamente ⭐"
        sleep 1

    fi

else
    echo "✅ Red intra encontrada ✅"
    echo ""
fi


# Crea una máquina virtual (maquina1) conectada a la red intra, con 1 GiB de RAM, que utilice como disco raíz maquina1.qcow2 y que se inicie automáticamente. Arranca la máquina. Modifica el fichero /etc/hostname con maquina1.

echo "⭐ Creando máquina virtual maquina1 ⭐"
virt-install --connect qemu:///system --virt-type kvm --name maquina1 --os-variant debian10 --network network=intra --disk maquina1.qcow2 --import --memory 1024 --vcpus 2 --noautoconsole > /dev/null
virt-install -c qemu:///system  autostart maquina1 > /dev/null
sleep 10
echo "⭐ Máquina virtual maquina1 creada correctamente ⭐"

echo "⭐ Modificando el fichero /etc/hostname con maquina1 ⭐"


echo "⭐ Fichero /etc/hostname modificado correctamente ⭐"

echo "⭐ Máquina virtual maquina1 creada correctamente ⭐"



