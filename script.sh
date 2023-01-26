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

  # Comprobamos si existe el fichero

echo "⭐ Comprobando si existe el fichero de red intra ⭐"
echo ""
sleep 2

if [ ! -f /etc/libvirt/qemu/networks/intra.xml ]; then
    echo "❌ SE VA A CREAR EL FICHERO intra ❌"
    echo ""
    sleep 2
    
    # Comprobar si esta como root
    if [ "$EUID" -ne 0 ]
    then echo "🆘❗❗ Por favor, ejecuta el script como root ❗❗🆘"
        exit
    
    else
        echo "⭐ Creando fichero de configuración de la red intra ⭐"
        echo "
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
        sleep 10
    fi

else
    echo "✅ Fichero intra encontrado ✅"
    echo ""
fi


  # Comprobamos si existe la red y la arrancamos

echo "⭐ Comprobando si existe la red intra ⭐"
echo ""
sleep 2

if virsh -c qemu:///system net-list --all | grep "intra"; then
    echo "✅ Red intra encontrada ✅"
    echo ""

else
    echo "❌ Red intra no encontrada ❌"
    echo ""
    echo "⭐ Creando red intra ⭐"
    virsh net-define /etc/libvirt/qemu/networks/intra.xml > /dev/null
    virsh net-start intra > /dev/null
    virsh net-autostart intra > /dev/null
    echo "⭐ Red intra creada correctamente ⭐"
    echo ""
    sleep 2
fi


# Crea una máquina virtual (maquina1) conectada a la red intra, con 1 GiB de RAM, que utilice como disco raíz maquina1.qcow2 y que se inicie automáticamente. Arranca la máquina. Modifica el fichero /etc/hostname con maquina1.

echo "⭐ Creando máquina virtual maquina1 ⭐"
echo ""
sleep 2

  # Comprobamos si existe la máquina virtual

if virsh -c qemu:///system list --all | grep "maquina1"; then
    echo "✅ Máquina virtual maquina1 encontrada ✅"
    echo ""

else

    echo "❌ Máquina virtual maquina1 no encontrada ❌"
    echo ""

    echo "⭐ Creando máquina virtual maquina1 ⭐"
    virt-install --connect qemu:///system --virt-type kvm --name maquina1 --os-variant debian10 --network network=intra --disk maquina1.qcow2 --import --memory 1024 --vcpus 2 --noautoconsole >/dev/null
    virsh -c qemu:///system autostart maquina1 >/dev/null
    echo "⭐ Máquina virtual maquina1 creada correctamente ⭐"
    echo ""
    sleep 23
fi

  # Verificamos que la máquina virtual existe y configuramos

if virsh list --all | grep -q "maquina1"; then
    ip=$(virsh -c qemu:///system domifaddr maquina1 | grep 10.10.20 | awk '{print $4}' | sed 's/...$//')
    echo "⭐ IP de la máquina virtual maquina1: $ip ⭐"
    echo ""
    sleep 2
    echo "⭐ Modificando el hostname a maquina1 ⭐"
    echo ""
    ssh-keyscan "$ip" >> ~/.ssh/known_hosts 2>/dev/null
    ssh -i virt debian@"$ip" "sudo hostnamectl set-hostname maquina1"
    ssh -i virt debian@"$ip" "sudo sh -c 'echo "127.0.0.1 maquina1" > /etc/hosts'" 2>/dev/null
    echo "⭐ Modificado correctamente ⭐"
    echo ""
    sleep 2

else

    echo "❌ No se ha podido crear la máquina virtual ❌"
    echo ""
    exit 1

fi




