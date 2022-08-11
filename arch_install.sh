#!/bin/sh

# Montaje de las particiones
# 
# $1: particion para /
# $2: particion para datos
# $3: particion para datos
# 

if [[ $# -eq 0 ]]; then
	echo "No se han indicado particiones."
fi

echo "Montando $1 en /..."
mount $1 /mnt &

if [[ $# -gt 1 ]]; then
	echo -n "Punto de montaje para $2: "
	read punto1
	mount $2 &punto1 &
fi

if [[ $# -gt 2 ]]; then
	echo "Punto de montaje para $3: "
	read punto2
	mount $3 $punto2 &
fi

# Instalación de paquetes 

echo "Instalando el sistema..."
pacstrap /mnt linux-lts linux-firmware base base-devel wpa_supplicant networkmanager dhcpcd os-prober nano grub ntfs-3g 

# generar fstab

echo "Generando fstab para el sistema..."
genfstab -U /mnt > /mnt/etc/fstab

# Contraseñas y usuarios

echo "Estableciendo contraseña para el usuario root..."
arch-chroot /mnt passwd

echo -n "Nombre del usuario: "
read usuario
arch-chroot /mnt useradd -m $usuario

echo "Estableciendo contraseña para el usuario $usuario..."
arch-chroot /mnt passwd $usuario

echo "Creando usuario..."
arch-chroot /mnt usermod -aG wheel $usuario
sed 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' < /mnt/etc/sudoers > /mnt/etc/sudoers.b &
mv /mnt/etc/sudoers.b /mnt/etc/sudoers &

# idioma y archivos
echo "Estableciendo idioma y generando archivos necesarios..."
sed 's/#es_ES.UTF-8 UTF-8/es_ES.UTF-8 UTF-8/' < /mnt/etc/locale.gen > /mnt/etc/locale.gen.b &

mv /mnt/etc/locale.gen.b /mnt/etc/locale.gen &
locale-gen &

echo KEYMAP=es > /mnt/etc/vconsole.conf &

echo -n "Nombre del equipo: "
read name
echo $name > /mnt/etc/hostname

echo "127.0.0.1\tlocalhost" >> /mnt/etc/hosts
echo "::1\t\tlocalhost" >> /mnt/etc/hosts
echo "127.0.0.1\t$name.localhost $name" >> /mnt/etc/hosts

# instalar grub

echo -n "Ruta para instalar el cargador de arranque: "
read grub

echo "Instalando el cargador de arranque"
arch-chroot /mnt grub-install $grub &
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg &
