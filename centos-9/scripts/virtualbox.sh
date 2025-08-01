#!/bin/bash
set -e

echo "==> Installation des VirtualBox Guest Additions..."

# Variables
VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
VBOX_ISO="/home/vagrant/VBoxGuestAdditions_${VBOX_VERSION}.iso"

# Vérification de la présence de l'ISO
if [ ! -f "$VBOX_ISO" ]; then
    echo "ISO VirtualBox Guest Additions non trouvé, téléchargement..."
    curl -fsSL "http://download.virtualbox.org/virtualbox/${VBOX_VERSION}/VBoxGuestAdditions_${VBOX_VERSION}.iso" -o "$VBOX_ISO"
fi

# Montage de l'ISO
mkdir -p /mnt/vbox
mount -o loop "$VBOX_ISO" /mnt/vbox

# Installation des Guest Additions
cd /mnt/vbox
echo "yes" | ./VBoxLinuxAdditions.run || echo "VBoxLinuxAdditions.run exited with non-zero code, but that's expected"

# Nettoyage
umount /mnt/vbox
rm -rf /mnt/vbox
rm -f "$VBOX_ISO"
rm -f /home/vagrant/.vbox_version

# Ajout de l'utilisateur vagrant au groupe vboxsf
usermod -a -G vboxsf vagrant

echo "==> Installation VirtualBox Guest Additions terminée"