#!/bin/sh

# Montaje de las particiones
# 
# $1: particion para /
# $2: particion para /home
# $3: particion para /boot
# 

echo "Montando $1 en /..."
mount $1 /mnt &

if [[ $# -gt 1 ]]; then
	echo "Montando $2 en /home..."
	mount $2 /mnt &
fi

if [[ $# -gt 2 ]]; then
	echo "Montando $3 en /boot..."
	mount $3 /mnt &
fi

# Instalación de paquetes 

echo "Instalando el sistema..."
pacstrap /mnt linux-lts linux-firmware base base-devel wpa-supplicant networkmanager dhcpcd os-prober nano grub ntfs-3g

# generar fstab

echo "Generando fstab para el sistema..."
genfstab -U /mnt > /mnt/etc/fstab

arch-chroot /mnt

# Contraseñas y usuarios

echo "Estableciendo contraseña para el usuario root..."
passwd

echo -n "Nombre del usuario: "
read usuario
useradd -m $usuario

echo "Estableciendo contraseña para el usuario $usuario..."
passwd $usuario

echo "Creando usuario..."
usermod -aG wheel $usuario
sed 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' < /etc/sudoers > /etc/sudoers.b &
mv /etc/sudoers.b /etc/sudoers &

# idioma y archivos
echo "Estableciendo idioma y generando archivos necesarios..."
ed 's/#es_ES.UTF-8 UTF-8/es_ES.UTF-8 UTF-8/' < /etc/locale.gen > /etc/locale.gen.b &

mv /etc/locale.gen.b /etc/locale.gen &
locale-gen &

echo KEYMAP=es > /etc/vconsole.conf &

echo -n "Nombre del equipo: "
read name
echo $name > /etc/hostname

echo "127.0.0.1\tlocalhost" >> /etc/hosts
echo "::1\t\tlocalhost" >> /etc/hosts
echo "127.0.0.1\t$name.localhost $name" >> /etc/hosts

# instalar grub

echo -n "Ruta para instalar el cargador de arranque: "
read grub

echo "Instalando el cargador de arranque"
grub-install $grub &
grub-mkconfig -o /boot/grub/grub.cfg &
