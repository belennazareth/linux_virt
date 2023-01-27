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
    megadl https://mega.nz/file/5iYE1QDY#94qGT8iHVpDCLK6b85XWsrJvlg-EJ77n2tUXBkuKYaw
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
echo "----------------------------------------------------------------------"
ls -la | grep maquina1.qcow2
echo "----------------------------------------------------------------------"
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

echo "Creando disco de datos 🐸 🐛 🐢 🐱 🐣 🐝 🦐 🐯 🦊 🐞 🐙 🐷 🐔 🦩 🦄 🐦 🐬 🐟"
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

if virsh -c qemu:///system net-list --all | grep "intra" > /dev/null; then
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

if virsh -c qemu:///system list --all | grep "maquina1" > /dev/null; then
    echo "✅ Máquina virtual maquina1 encontrada ✅"
    echo ""

else

    echo "❌ Máquina virtual maquina1 no encontrada ❌"
    echo ""

    echo "⭐ Creando máquina virtual maquina1 ⭐"
    virt-install --connect qemu:///system --virt-type kvm --name maquina1 --disk maquina1.qcow2 --os-variant debian10 --memory 1024 --vcpus 1 --network network=intra --autostart --import --noautoconsole >/dev/null
    virsh -c qemu:///system autostart maquina1 >/dev/null
    echo "⭐ Máquina virtual maquina1 creada correctamente ⭐"
    echo ""
    sleep 23
fi

  # Verificamos que la máquina virtual existe y configuramos

if virsh -c qemu:///system list --all | grep "maquina1" > /dev/null; then
    ip=$(virsh -c qemu:///system domifaddr maquina1 | awk '{print $4}' | cut -d "/" -f 1 | sed -n 3p)
    echo "⭐ IP de la máquina virtual maquina1: "$ip" ⭐"
    echo ""
    sleep 2

    echo "⭐ Modificando el hostname a maquina1 ⭐"
    echo ""
    ssh-keyscan "$ip" >> ~/.ssh/known_hosts 2>/dev/null
    ssh -i virt debian@"$ip" "sudo hostnamectl set-hostname maquina1"
    echo "⭐ Modificado correctamente ⭐"
    echo ""
    sleep 2

    virsh -c qemu:///system reboot maquina1 >/dev/null
    echo "⭐ Reiniciando la máquina ⭐"
    echo "⭐ Esto puede tardar unos minutos ⭐"
    echo " 🕦 🕧 🕛 🕤 🕚 🕜 🕗 🕑 🕒 🕙 🕣 🕢 🕥 "
    sleep 30

else

    echo "❌ No se ha podido crear la máquina virtual ❌"
    echo ""
    exit 1

fi


# Crea un volumen adicional de 1 GiB de tamaño en formato RAW ubicado en el pool por defecto

  # Comprobamos si existe el volumen

echo "⭐ Comprobando si existe el volumen adicional ⭐"
echo ""
sleep 2

if virsh -c qemu:///system vol-list default | grep "adicional.raw" >/dev/null; then
    echo "✅ Volumen adicional encontrado ✅"
    echo ""

else
    echo "❌ Volumen adicional no encontrado ❌"
    echo ""
    echo "⭐ Creando volumen adicional ⭐"
    virsh -c qemu:///system vol-create-as default adicional.raw 1G >/dev/null
    echo "⭐ Volumen adicional creado correctamente ⭐"
    echo ""
    sleep 2
fi


# Una vez iniciada la MV maquina1, conecta el volumen a la máquina, crea un sistema de ficheros XFS en el volumen y móntalo en el directorio /var/www/html. Ten cuidado con los propietarios y grupos que pongas, para que funcione adecuadamente el siguiente punto.

  # Comprobamos por ssh si tiene un volumen vdb en la máquina virtual maquina1

echo "⭐ Comprobando si existe el volumen vdb en maquina1 ⭐"
echo ""
sleep 2

ip=$(virsh -c qemu:///system domifaddr maquina1 | awk '{print $4}' | cut -d "/" -f 1 | sed -n 3p)

if ssh -i virt debian@"$ip" "lsblk | grep vdb" >/dev/null; then
    echo "✅ Volumen vdb encontrado ✅"
    echo "" 

else

    echo "❌ Volumen vdb no encontrado ❌"
    echo ""
    sleep 2

    echo "⭐ Conectando el volumen adicional a la máquina virtual maquina1 ⭐"
    echo ""
    virsh -c qemu:///system attach-disk maquina1 /var/lib/libvirt/images/adicional.raw vdb --driver=qemu --type disk --subdriver raw --persistent >/dev/null
    echo "⭐ Volumen adicional conectado correctamente ⭐"
    echo ""
    sleep 2

    echo "⭐ Dando formato XFS ⭐"
    echo ""
    ssh -i virt debian@"$ip" "sudo mkfs.xfs /dev/vdb" >/dev/null
    echo "⭐ Formateado correctamente ⭐"
    echo ""

    echo "⭐ Montando el volumen en /var/www/html ⭐"
    echo ""
    ssh -i virt debian@"$ip" 'sudo mkdir -p /var/www/html' 
    ssh -i virt debian@"$ip" "sudo mount /dev/vdb /var/www/html" >/dev/null 
    echo "⭐ Montado correctamente ⭐"
    echo ""
    sleep 2

    echo "⭐ Introduciendo en fstab ⭐"
    ssh -i virt debian@"$ip" "sudo -- bash -c 'echo "/dev/vdb        /var/www/html   xfs     defaults        0       0" >> /etc/fstab'"
    echo "⭐ Introducido correctamente ⭐"
    echo ""
    sleep 2

fi

# Instala en maquina1 el servidor web apache2. Copia un fichero index.html a la máquina virtual.

  # Comprobamos si apache2 está instalado

echo "⭐ Comprobando si apache2 está instalado ⭐"
echo ""
sleep 2

if ssh -i virt debian@"$ip" "dpkg -l | grep apache2" >/dev/null; then
    echo "✅ Apache2 instalado ✅"
    echo ""

else

    echo "❌ Apache2 no instalado ❌"
    echo ""
    sleep 2

    echo "⭐ Instalando apache2 ⭐"
    echo ""
    ssh -i virt debian@"$ip" "sudo apt update && sudo apt install apache2 -y" >/dev/null 2>&1
    echo "⭐ Instalado correctamente ⭐"
    echo ""
    sleep 2

    echo "⭐ Copiando index.html ⭐"
    echo ""
    scp -i virt index.html debian@"$ip":/home/debian >/dev/null
    ssh -i virt debian@"$ip" "sudo chown www-data:www-data /home/debian/index.html" >/dev/null
    ssh -i virt debian@"$ip" "sudo mv /home/debian/index.html /var/www/html" >/dev/null


    echo "⭐ Copiado correctamente ⭐"
    echo ""
    sleep 2

fi


# Muestra por pantalla la dirección IP de máquina1. Pausa el script y comprueba que puedes acceder a la página web.

echo "⭐ La dirección IP de la máquina virtual es: $ip ⭐"
echo "⭐ Puedes acceder a la página web en http://$ip ⭐"
echo ""
read -rp "✨ Pulsa una tecla para continuar 😺💛"

# Instala LXC y crea un linux container llamado container1.
  
  # Comprobamos si LXC está instalado

echo "⭐ Comprobando si LXC está instalado ⭐"
echo ""
sleep 2

if ssh -i virt debian@"$ip" "dpkg -l | grep lxc" >/dev/null; then
    echo "✅ LXC instalado ✅"
    echo ""

else

    echo "❌ LXC no instalado ❌"
    echo ""
    sleep 2

    echo "⭐ Instalando LXC ⭐"
    echo ""
    ssh -i virt debian@"$ip" "sudo apt update && sudo apt install lxc -y" >/dev/null 2>&1
    echo "⭐ Instalado correctamente ⭐"
    echo ""
    sleep 2

    echo "⭐ Creando container1 ⭐"
    echo ""
    ssh -i virt debian@"$ip" 'sudo lxc-create -n container1 -t debian -- -r bullseye' >/dev/null 2>&1
    echo "⭐ Creado correctamente ⭐"
    echo ""
    sleep 2

fi


# Añade una nueva interfaz a la máquina virtual para conectarla a la red pública (al punte br0).

  # Comprobamos si la interfaz enp5so está creada

echo "⭐ Comprobando si la interfaz enp5so está creada ⭐"
echo ""
sleep 2

if ssh -i virt debian@"$ip" "ip a | grep enp5so" >/dev/null; then
    echo "✅ Interfaz enp5so creada ✅"
    echo ""

else

    echo "❌ Interfaz enp5so no creada ❌"
    echo ""
    sleep 2

    echo "⭐ Modificando /etc/network/interfaces ⭐"
    echo ""
    ssh -i virt debian@"$ip" "sudo -- bash -c 'echo "auto enp5so" >> /etc/network/interfaces'"
    ssh -i virt debian@"$ip" "sudo -- bash -c 'echo "iface enp5so inet dhcp" >> /etc/network/interfaces'"
    echo "⭐ Modificado correctamente ⭐"

    echo "⭐ Apagando maquina1 ⭐"
    echo ""
    virsh -c qemu:///system shutdown maquina1 >/dev/null
    sleep 24

    echo "⭐ Añadiendo br0 ⭐"
    echo ""
    virsh -c qemu:///system attach-interface --domain maquina1 --type bridge --source br0 --model virtio --config >/dev/null
    
    echo "⭐ Encendiendo maquina1 ⭐"
    echo ""
    virsh -c qemu:///system start maquina1 >/dev/null
    sleep 24

fi


# Muestra la nueva IP que ha recibido.

ipbr=$(ssh debian@$ip 'ip address show enp5s0 | egrep -o -m 1 "(\b25[0-5]|\b2[0-4][0-9]|\b[01]?[0-9][0-9]?)(\.(25[0-4]|2[0-5][0-9]|[01]?[0-9][0-9]?)){3}" | egrep -v "255"')

echo "⭐ La nueva IP de la máquina virtual es: $ipbr ⭐"

# Apaga maquina1 y auméntale la RAM a 2 GiB y vuelve a iniciar la máquina.

echo "⭐ Apagando maquina1 ⭐"
echo ""

virsh -c qemu:///system shutdown maquina1 >/dev/null
sleep 24

echo "⭐ Aumentando RAM ⭐"
echo ""
virsh -c qemu:///system setmaxmem maquina1 2G --config >/dev/null
virsh -c qemu:///system setmem maquina1 2G --config >/dev/null

echo "⭐ Encendiendo maquina1 ⭐"
echo ""
virsh -c qemu:///system start maquina1 >/dev/null
sleep 24

# Crea un snapshot de la máquina virtual.

echo "⭐ Creando snapshot ⭐"
echo ""
virsh -c qemu:///system snapshot-create-as maquina1 --name snapshot1 --description "Snapshot de la máquina virtual" --disk-only --atomic >/dev/null

echo "⭐ Snapshot creado correctamente ⭐"
echo ""
echo "🌈🌸✨ Script finalizado ✨🌼🌊"
echo ""
